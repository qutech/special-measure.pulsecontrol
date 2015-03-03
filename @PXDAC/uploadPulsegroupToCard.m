function uploadPulsegroupToCard(self,name)



if ~ischar(name)
    error('No valid sequence name provided');
end

if ~isKey(self.storedPulsegroups,name)
    error('Pulsegroup %s can not be loaded into memory because it does not exist.',name);
end

pulsegroup = self.storedPulsegroups(name);
waveformArray = self.storedPulsegroups(name).waveformArray;

if ~isempty(pulsegroup.start)
    if pulsegroup.lastMemoryUpdate > pulsegroup.lastload
        fprintf('pulsegroup %s already uploaded.\n',name);
        return;
    else
        fprintf('pulsegroup %s is outdated and will be reloaded.\n',name);
        pulsegroup.start = [];
    end
end


%check mask
if waveformArray(1).channelMask ~= self.activeChannelMask
    self.setChannelMask(waveformArray(1).channelMask);
end


totalByteSize = [waveformArray(pulsegroup.pulseSequence.index).byteSize]*[pulsegroup.pulseSequence.nrep]';



%find free coherent space in memory
[start,index] = self.freeEnoughMemory( totalByteSize );


if isempty(index) || isempty(start)
    error('Out of board memory. Please erase some sequences from board.');
end

%
self.storedPulsegroups.move(name,index);

self.storedPulsegroups(name).start = start;
self.storedPulsegroups(name).totalByteSize = totalByteSize;

for playedPulse = pulsegroup.pulseSequence
    
    pulse = waveformArray(playedPulse.index);
    %check channelMask
    if pulse.channelMask ~= self.activeChannelMask
        error('Channel masks are not consistent.');
    end
    wfSize = pulse.byteSize;
    
    for i = 1:playedPulse.nrep
        
        calllib('PXDACMemoryManager','writeRAW',...
            uint32(start),...
            uint32(wfSize),...
            pulse.rawData);
        
        
        
        start = start + wfSize;
    end
end
PXDAC.testStatus( calllib('PXDACMemoryManager','synchronize',false) );
self.storedPulsegroups(name).lastMemoryUpdate = now;

end