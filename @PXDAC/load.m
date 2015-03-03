function load(self,grp,ind)
fprintf('PXDAC.load\n')

% ???
dind=find([grp.pulses(1).data.clk] == self.clk);


% fixme; emit an error if this changes zerochan and wlist.size ~= 25.
% The screwiness here is to get each channel with a unique offset/scale combo
[~, offsetchan] = unique(self.offset./self.scale);
offsets=self.offset(offsetchan);

channelMask = uint16(sum(2.^(self.getHardwareChannel(grp.chan)-1)));

%create pulsegroup object
if ~isKey(self.storedPulsegroups,grp.name)
    self.storedPulsegroups.add( PXDACPULSEGROUP(grp.name) );
end


%reserve memory (at least i hope so)
self.storedPulsegroups(grp.name).waveformArray = repmat( struct('pulse',PXDACPULSE.empty(0,0),'repetitions',0), 1,length(grp.pulses) );

for i = 1:length(grp.pulses)
    

    pulse = PXDACPULSE(channelMask,size(grp.pulses.data.wf,2));
    
    
    for virtChan = 1:size(grp.pulses(i).data(dind).wf, 1)
        
        hardChan = self.getHardwareChannel(grp.chan(virtChan));
        
        %skip virtual channels not belonging to this AWG
        if isempty(hardChan)
            continue;
        end
        
        %map to interval [0,2]
        data =  ((self.offset(min(hardChan,end)) + grp.pulses(i).data(dind).wf(virtChan, :))./self.scale(hardChan) + 1);
        
        %convert to uint16 0-2^14-1
        int16wf = uint16(min(...
                data*(2^(14-1) - 1),...
                2^(14)-1));
            
        pulse.writeToChannel(hardChan,int16wf);

        
    end
    
    self.storedPulsegroups(grp.name).waveformArray(i).pulse = pulse;

end

self.storedPulsegroups(grp.name).lastload = now;


end




