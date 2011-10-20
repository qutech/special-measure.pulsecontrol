function zerolen = awgload(grp, ind, zerolen)
% zerolen = awgload(grp)
% load pulses from group to AWG. 

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.


%global plsdata;
global awgdata;

%nchan = length(grp.chan); % alternatively use data size
%nchan = size(grp.pulses(1).data, 1); % assumed same for all.

awgcntrl('stop'); %changing pulses while running is slow.
awgsyncwaveforms(); % make sure the waveform list is up-to-date.
dosave = false;
nchan = length(awgdata.chans); % alternatively use awgdata or data size
  

  % fixme; emit an error if this changes zerochan and wlist.size ~= 25.
  % The screwiness here is to get each channel with a unique offset/scale combo
[offsets offsetchan awgdata.zerochan] = unique(awgdata.offset./awgdata.scale);
offsets=awgdata.offset(offsetchan);

% create trig pulse (and corresponding 0) if waveform list empty.
if query(awgdata.awg, 'WLIS:SIZE?', '%s\n', '%i') == 25 % nothing loaded (except predefined)
    zdata=zeros(1,awgdata.triglen);
    zmarker=repmat(1,1,awgdata.triglen);
    awgloadwfm(zdata,zmarker,sprintf('trig_%08d',awgdata.triglen),1,1);
                
    for l=1:length(offsets)
        awgloadwfm(zdata,zmarker,sprintf('zero_%08d_%d',awgdata.triglen,l),offsetchan(l),1);
    end
    dosave = 1;
    awgdata.zeropls = awgdata.triglen;
end

for i = 1:length(grp.pulses)
    npts = size(grp.pulses(i).data.wf, 2);
    
    if ~any(awgdata.zeropls == npts) % create zero if not existing yet        
        zdata=zeros(1,npts);                
        for l=1:length(offsets)
            zname=sprintf('zero_%08d_%d', npts, l);
            awgloadwfm(zdata,zdata,zname,offsetchan(l),1);
        end
        zdata=[];
        awgdata.zeropls(end+1) = npts;
        dosave = 1;
    end

    for j = 1:size(grp.pulses(i).data.wf, 1)        
        if any(abs(grp.pulses(i).data.wf(j, :)) > awgdata.scale(j)/(2^14)) || any(grp.pulses(i).data.marker(j,:) ~= 0)
            name = sprintf('%s_%05d_%d', grp.name, ind(i), j);
    
            if isempty(strmatch(name,awgdata.waveforms))                
              fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
              awgdata.waveforms{end+1}=name;  
              err = query(awgdata.awg, 'SYST:ERR?');
              if ~isempty(strfind(err,'E11113'))
                 fprintf(err(1:end-1));
                 error('Error loading waveform; AWG is out of memory.  Try awgclear(''all''); ');
              end              
            end            
            awgloadwfm(grp.pulses(i).data.wf(j,:), uint16(grp.pulses(i).data.marker(j,:)), name, grp.chan(j), 0);
            zerolen(ind(i), j) = -npts;
        else
            zerolen(ind(i), j) = npts;
        end
    end
end
awgcntrl('clr');

% if the pulse group is added, update it's load time.
ind=awggrpind(grp.name);
if ~isnan(ind)
    awgdata.pulsegroups(ind).lastload=now;
end

if dosave
    awgsavedata;
end
end


function zerolen = awgloadwfm(data, marker, name, chan,define)
% Send waveform 'data,marker' to the awg with name 'name' intended for channel c.
% data is scaled and offset by awgdata.scale and awgdata.offset *before* sending.
global awgdata;

if exist('define','var') && define
   fprintf(awgdata.awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, length(data))); 
   awgdata.waveforms{end+1}=name;
end
chunksize=65536;
if(size(data,1) > size(data,2))
    data=data';
end
    data=(awgdata.offset(min(chan,end)) + data)./awgdata.scale(chan) + 1;
    tb=find(data > 2);
    tl=find(data < 0);
    if ~isempty(tb) || ~isempty(tl)
      %  fprintf('Pulse exceeds allowed range: %g - %g\n',min(data),max(data));
        data(tb) = 2;
        data(tl) = 0;
    end
    data = uint16(min(data*(2^(awgdata.bits-1) - 1), 2^(awgdata.bits)-1)) + uint16(marker) * 2^(awgdata.bits);
    npts = length(data);
    
    for os=0:chunksize:npts
        if os + chunksize >= npts
            fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, npts-os,2 * (npts-os)),...
                typecast(data((os+1):end), 'uint8')]);
        else
            fwrite(awgdata.awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, chunksize,2 * chunksize),...
                typecast(data((os+1):(os+chunksize)), 'uint8')]);
        end
        fprintf(awgdata.awg,'');
    end
end


