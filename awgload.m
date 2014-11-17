function zerolen = awgload(grp, ind)
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

for a=1:length(awgdata)
    
    dind=find([grp.pulses(1).data.clk] == awgdata(a).clk);
    
    nchan = length(awgdata(a).chans); % alternatively use awgdata or data size
    
    
    % fixme; emit an error if this changes zerochan and wlist.size ~= 25.
    % The screwiness here is to get each channel with a unique offset/scale combo
    [offsets offsetchan awgdata(a).zerochan] = unique(awgdata(a).offset./awgdata(a).scale);
    offsets=awgdata(a).offset(offsetchan);
    
    % create trig pulse (and corresponding 0) if waveform list empty.
    if query(awgdata(a).awg, 'WLIS:SIZE?', '%s\n', '%i') == 25 % nothing loaded (except predefined)
        zdata=zeros(1,awgdata(a).triglen);
        zmarker=repmat(1,1,awgdata(a).triglen);
        awgloadwfm(a,zdata,zmarker,sprintf('trig_%08d',awgdata(a).triglen),1,1);
        
        for l=1:length(offsets)
            awgloadwfm(a,zdata,zmarker,sprintf('zero_%08d_%d',awgdata(a).triglen,l),offsetchan(l),1);
        end
        dosave = 1;
        awgdata(a).zeropls = awgdata(a).triglen;
    end
    nzpls=0;    
    for i = 1:length(grp.pulses)
        npts = size(grp.pulses(i).data(dind).wf, 2);        
        if ~any(awgdata(a).zeropls == npts) % create zero if not existing yet
            zdata=zeros(1,npts);
            for l=1:length(offsets)
                zname=sprintf('zero_%08d_%d', npts, l);
                awgloadwfm(a,zdata,zdata,zname,offsetchan(l),1);
            end
            zdata=[];
            awgdata(a).zeropls(end+1) = npts;
            dosave = 1;
        end

        for j = 1:size(grp.pulses(i).data(dind).wf, 1)
            ch=find(grp.chan(j)==awgdata(a).chans);
            if isempty(ch)
                continue;
            end
            if any(abs(grp.pulses(i).data(dind).wf(j, :)) > awgdata(a).scale(ch)/(2^awgdata(a).bits)) || any(grp.pulses(i).data(dind).marker(j,:) ~= 0)
                name = sprintf('%s_%05d_%d', grp.name, ind(i), j);
                
                if isempty(strmatch(name,awgdata(a).waveforms))
                    fprintf(awgdata(a).awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
                    awgdata(a).waveforms{end+1}=name;
                    err = query(awgdata(a).awg, 'SYST:ERR?');
                    if ~isempty(strfind(err,'E11113'))
                        fprintf(err(1:end-1));
                        error('Error loading waveform; AWG is out of memory.  Try awgclear(''all''); ');
                    end
                end
                awgloadwfm(a,grp.pulses(i).data(dind).wf(j,:), uint16(grp.pulses(i).data(dind).marker(j,:)), name, ch, 0);
                zerolen{a}(ind(i), j) = -npts;
                nzpls=1;
            else
                zerolen{a}(ind(i), j) = npts;
            end
        end
    end
    % If no non-zero pulses were loaded, make a dummy waveform so awgclear
    % knows this group was in memory.
    if nzpls == 0
        name=sprintf('%s_1_1',grp.name);
        npts=256;
        if isempty(strmatch(name,awgdata(a).waveforms))
            fprintf(awgdata(a).awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
            awgdata(a).waveforms{end+1}=name;
        end
        awgloadwfm(a,zeros(1,npts), zeros(1,npts), name, 1, 0);
    end
end

% if the pulse group is added, update it's load time.
ind=awggrpind(grp.name);
if ~isnan(ind)
    for i=1:length(awgdata)
      awgdata(i).pulsegroups(ind).lastload=now;
    end
end

if dosave
    awgsavedata;
end

end


function zerolen = awgloadwfm(a, data, marker, name, chan,define)
% a is the awg index.
% Send waveform 'data,marker' to the awg with name 'name' intended for channel c.
% data is scaled and offset by awgdata.scale and awgdata.offset *before* sending.
global awgdata;
start = now;
if exist('define','var') && define
   fprintf(awgdata(a).awg, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, length(data))); 
   awgdata(a).waveforms{end+1}=name;
end
chunksize=65536;
if(size(data,1) > size(data,2))
    data=data';
end
    data=(awgdata(a).offset(min(chan,end)) + data)./awgdata(a).scale(chan) + 1;
    tb=find(data > 2);
    tl=find(data < 0);
    if ~isempty(tb) || ~isempty(tl)
      %  fprintf('Pulse exceeds allowed range: %g - %g\n',min(data),max(data));
        data(tb) = 2;
        data(tl) = 0;
    end % 14 bit data offset is hard-coded in the AWG.
    data = uint16(min(data*(2^(14-1) - 1), 2^(14)-1)) + uint16(marker) * 2^14;
    npts = length(data);
    for os=0:chunksize:npts
        if os + chunksize >= npts
            fwrite(awgdata(a).awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, npts-os,2 * (npts-os)),...
                typecast(data((os+1):end), 'uint8')]);
        else
            fwrite(awgdata(a).awg, [sprintf('WLIS:WAV:DATA "%s",%d,%d,#7%07d', name, os, chunksize,2 * chunksize),...
                typecast(data((os+1):(os+chunksize)), 'uint8')]);
        end
        fprintf(awgdata(a).awg,'');
    end
    time=(now-start)*24*60*60;
    %fprintf('Load time: %g seconds for %g points (%g bytes/sec)\n',time, npts,npts*2/time);
end


