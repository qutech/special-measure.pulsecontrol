function load(self,grp,ind)
fprintf('awg.load\n')
% zerolen = awgload(grp)
% load pulses from group to AWG.

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

self.control('stop'); %changing pulses while running is slow.
self.syncwaveforms(); % make sure the waveform list is up-to-date.

dind=find([grp.pulses(1).data.clk] == self.clk);


% fixme; emit an error if this changes zerochan and wlist.size ~= 25.
% The screwiness here is to get each channel with a unique offset/scale combo
[offsets offsetchan self.zerochan] = unique(self.offset./self.scale);
offsets=self.offset(offsetchan);

dosave = false;

% create trig pulse (and corresponding 0) if waveform list empty.
if query(self.handle, 'WLIS:SIZE?', '%s\n', '%i') == 25 % nothing loaded (except predefined)
    zdata=zeros(1,self.triglen);
    zmarker=repmat(1,1,self.triglen);
    self.loadwfm(zdata,zmarker,sprintf('trig_%08d',self.triglen),1,1);
    
    for l=1:length(offsets)
        self.loadwfm(zdata,zmarker,sprintf('zero_%08d_%d',self.triglen,l),offsetchan(l),1);
    end
    dosave = true;
    self.zeropls = self.triglen;
end



nzpls=0;



for i = 1:length(grp.pulses)
    npts = size(grp.pulses(i).data(dind).wf, 2);
    if ~any(self.zeropls == npts) % create zero if not existing yet
        zdata=zeros(1,npts);
        for l=1:length(offsets)
            zname=sprintf('zero_%08d_%d', npts, l);
            self.loadwfm(zdata,zdata,zname,offsetchan(l),1);
        end
        zdata=[];
        self.zeropls(end+1) = npts;
        dosave = true;
    end
    
    for j = 1:size(grp.pulses(i).data(dind).wf, 1)
        
        ch = self.getHardwareChannel(grp.chan(j));
        
        %virtual channels not belonging to this AWG
        if isempty(ch)
            continue;
        end

        % data of channel 2 is uploaded seperatly and not as a zeropulse
        if any(abs(grp.pulses(i).data(dind).wf(j, :)) > self.scale(ch)/(2^self.resolution)) || any(grp.pulses(i).data(dind).marker(j,:) ~= 0)
            name = sprintf('%s_%05d_%d', grp.name, ind(i), j);
            
            if isempty(strmatch(name,self.waveforms))
                fprintf(self.handle, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
                self.waveforms{end+1}=name;
                err = query(self.handle, 'SYST:ERR?');
                if ~isempty(strfind(err,'E11113'))
                    fprintf(err(1:end-1));
                    error('Error loading waveform; AWG is out of memory.  Try awgclear(''all''); ');
                end
            end
            self.loadwfm(grp.pulses(i).data(dind).wf(j,:), uint16(grp.pulses(i).data(dind).marker(j,:)), name, ch, 0);
            zerolen(ind(i), j) = -npts;
            nzpls=1;
        else
            zerolen(ind(i), j) = npts;
        end
    end
end

% If no non-zero pulses were loaded, make a dummy waveform so awgclear
% knows this group was in memory.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%consider removoing
if nzpls == 0
    name=sprintf('%s_1_1',grp.name);
    npts=256;
    if isempty(strmatch(name,self.waveforms))
        fprintf(self.handle, sprintf('WLIS:WAV:NEW "%s",%d,INT', name, npts));
        self.waveforms{end+1}=name;
    end
    self.loadwfm(zeros(1,npts), zeros(1,npts), name, 1, 0);
end

if ~isKey(self.storedPulsegroups,grp.name)
    self.storedPulsegroups.add( TekPULSEGROUP(grp.name) );
end

%update it's load time.
self.storedPulsegroups(grp.name).lastload = now;

    
end

if dosave
    self.savedata;
end
end




