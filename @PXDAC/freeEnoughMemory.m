function [start, index] = freeEnoughMemory(self,requiredSize)
    uploadedGroups = find( ~isempty(self.storedPulsegroups.mData.start) );
    
    %simple algorithm: delete the oldest groups until there is enough
    %memory
    
    if isempty(uploadedGroups)
        start = 0; index = 1;
        return;
    end
    
    alignment = 2^13;
    
    while true
        start = 0;
        index = 1;
        for index = 1:uploadedGroups
            if self.storedPulsegroups.mData(index).start-start < requiredSize
                start = uint32( ceil( double(self.storedPulsegroups.mData(index).start + self.storedPulsegroups.mData(index).start)/double(alignment) ) * alignment );
            else
                %found enough free memory
                break;

            end
        end
        
        if self.totalMemory - start >= requiredSize
            %found enough free memory
            break;
        end
        
        oldestGroup = find( storedPulsegroups.mData(uploadedGroups).lastActivation == min(storedPulsegroups.mData(uploadedGroups).lastActivation) );
        
        self.storedPulsegroups.mData(oldestGroup).start = [];
        uploadedGroups(oldestGroup) = [];
        
        if isempty(uploadedGroups)
            error('This is a bug or the pulsegroup is too large');
        end
    end
end