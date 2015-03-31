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

fprintf('loading %s...\n',pulsegroup.name);

%check mask
if waveformArray(1).channelMask ~= self.activeChannelMask
    self.setChannelMask(waveformArray(1).channelMask);
end


totalByteSize = [waveformArray(pulsegroup.pulseSequence.index).byteSize]*[pulsegroup.pulseSequence.nrep]';

if mod(totalByteSize,8192) ~= 0
    error('The total length of a pulsegroup must be a multiple of 8192 but it is %d*8192',totalByteSize/8192);
end

%find free coherent space in memory
[startOfPulsegroup,index] = self.freeEnoughMemory( totalByteSize );


if isempty(index) || isempty(startOfPulsegroup)
    error('Out of board memory. Please erase some sequences from board.');
end

%

start = startOfPulsegroup;
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

self.storedPulsegroups.move(name,index);
self.storedPulsegroups(name).start = startOfPulsegroup;
self.storedPulsegroups(name).totalByteSize = totalByteSize;

PXDAC.testStatus( calllib('PXDACMemoryManager','synchronize',0) );
self.storedPulsegroups(name).lastMemoryUpdate = now;

end