classdef VAWG < handle
    properties (SetAccess = protected, GetAccess = public)
        awgs;
        
        %channel mapping
        virtualToHardware = {};
        
        %trigger length in nanoseconds
        triggerLength = 4000;
    end

    methods
        add(self,groups);
            
        function zerolen = zero(self,grp,ind,zerolen)
            for awg = 1:length(self.awgs)
                zerolen = self.awgs(awg).zeroLength(grp,ind,zerolen);
            end    

        end
        
        function index = addAWG(self,awg)
            if ~isa(awg,'AWG')
                error('Object is no AWG.');
            else
                if ~isempty(self.awgs)
                    if find( strcmp({self.awgs.identifier},awg.identifier) )
                        error('AWG with identifier %s already exists.',awg.identifier);
                    end
                end
                
                self.awgs = [self.awgs(:) awg];
                index = length(self.awgs);
            end
        end
        
        function removeAWG(self,awg)
            index = self.getIndex(awg);
            
            self.awgs(index).virtualChannels = [];
            
            for virt = 1:length(self.virtualToHardware)
                todelete = [];
                for entry = 1:length( self.virtualToHardware{virt} )
                    if self.virtualToHardware{virt}{entry}(1) == index
                        todelete(end+1) = entry;
                    end
                end
                self.virtualToHardware{virt}(todelete) = [];
            end
            
            
            self.awgs(index) = [];
        end
        
        function index = getIndex(self,awg)
            if isa(awg,'AWG')
                index = find( eq(awg,self.awgs) );
            elseif ischar(awg)
                index = find( strcmp({self.awgs.identifier},awg) );
            elseif isinteger(awg) || isfloat(awg)
                index = awg;
            else
                error('Recieved an invalid type to determine index.');
            end
            
            if length(self.awgs)<index
                error('Index %i to large. VAWG only knows %i AWGs.',index,length(self.awgs));
            end
        end
        
        function createVirtualChannel(self,awg,hardware,virtual)
            index = self.getIndex(awg);
            
            if hardware> self.awgs(index).nChannels
                error('AWG %s only has %i hardware channels. Requested was %i',self.awgs(index).nChannels,hardware);
            end
            
            if size(self.virtualToHardware,2) < virtual
                self.virtualToHardware{virtual}{1} = [index hardware];
            else
                self.virtualToHardware{virtual}{end+1} = [index hardware];
            end
            
            self.awgs(index).virtualChannels(hardware) = virtual;
        end
        
        function removeVirtualChannel(self,virtualChannel)
            if size(self.virtualToHardWare,2)<virtualChannel || isempty(self.virtualToHardWare{virtualChannel})
                return;
            end
            
            for indexhardware = self.awgs{virtualChannel}
                index = indexhardware(1);
                hardware = indexhardware(2);
                
                self.awgs(index).virtualChannels(hardware) = 0;
            end
            self.virtualToHardWare{virtualChannel} = [];
        end
        
        function removeVirtualChannelMapping(self,virtualChannel,awg,hardware)
            index = getIndex(awg);
            if size(self.virtualToHardWare,2)<virtualChannel || isempty(self.virtualToHardWare{virtualChannel})
                return;
            end
            
            entry = find(self.virtualToHardWare{virtualChannel} == [index hardware]);
            if isempty(entry)
                return;
            end
            self.awgs(index).virtualChannels(hardware) = 0;
            self.virtualToHardWare{virtualChannel}{entry} = [];
        end
        
        function setActivePulseGroup(self,groupName)
            for awg = self.awgs
                awg.setActivePulseGroup(groupName);
            end
        end
        
        function arm(self)
            for awg = self.awgs
                awg.arm();
            end
        end
        
        function val = isPlaybackInProgress(self)
            activePlaybacks = zeros(1,length(self.awgs));
            for awg = 1:length(self.awgs)
                activePlaybacks(awg) = self.awgs(awg).isPlaybackInProgress();
            end
            
            val = sum(activePlaybacks)>0;
            
            if sum(activePlaybacks) ~= 0 && sum(activePlaybacks) ~= length(self.awgs)
                warning('One AWGs is still playing while another one has finished!');
            end
        end
        
        function setTriggerLength(self,triglen)
            self.triggerLength = triglen;
        end
        function triglen = getTriggerLength(self)
            triglen = self.triggerLength;
        end
    end
end