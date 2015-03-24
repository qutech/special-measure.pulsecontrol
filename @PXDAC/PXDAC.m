classdef PXDAC < AWG
    properties (Constant,GetAccess = public)
        nChannels = 4;
        possibleResolutions = 14; %may implement 8 if needed
        
        %in bytes
        totalMemory = 2^30;
        
        % memory manager chunk size
        minimalChunkSize = 2^13;
    end
    
    properties (Constant,Abstract,GetAccess = public)
        allowedVoltageRange;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        handle;
        serialNumber;
        
        
        
        %         wfMap; % equivalent to wf on AWG
        
        % Map to structs with fields
        % start, length (position in memory)
        % waveforms (array of PXDACPULSE)
        % inherited storedPulsegroups;
        
        
        %if the ChannelMask changes the whole RAM is dropped
        activeChannelMask;
    end
    
    methods (Access = protected)
        % constructor
        function obj = PXDAC(id,index)
            obj = obj@AWG(id);
            
            %check architecture
            if ~strcmpi(computer('arch'), 'win64')
                error('This driver only supports 64 bit windows');
            end
            
            %load library
            if ~libisloaded('PXDAC4800_64')
                loadlibrary('PXDAC4800_64.dll', 'pxdac4800_wrapper.h');
            end
            
            
            %check if device is present
            deviceCount = calllib('PXDAC4800_64','GetDeviceCountXD48');
            if deviceCount == 0
                error('No device present.');
            elseif index>deviceCount
                error('Device %i is not present. There are only %i devices.',index,deviceCount);
            end
            
            obj.handle = libpointer('ulongPtr',uint32(0));
            
            % connect
            obj.library('ConnectToDeviceXD48',...
                obj.handle,...
                index);
            
            
            temp = libpointer('uint32Ptr', uint32(0));
            obj.library('GetSerialNumberXD48',obj.handle,temp);
            obj.serialNumber = get(temp);
            obj.serialNumber = obj.serialNumber.Value;
            clear('temp');
            
            % init with defaults
            % obj.resetToPowerupDefault();
            %
            obj.activeChannelMask = uint16(15);
            
            obj.clk = 100e6;
            
            obj.library('SetTriggerModeXD48',obj.handle,2);%single shot trigger mode
            
            if ~libisloaded('PXDACMemoryManager')
                loadlibrary('C:\Users\humpohl\Documents\Visual Studio 2013\Projects\PXDACMemoryManager\x64\Debug\PXDACMemoryManager.dll','C:\Users\humpohl\Documents\Visual Studio 2013\Projects\PXDACMemoryManager\PXDAC_memory_manager.h')
            end
            
            %initialize memory manager
            chunkexponent = 22; %2^22 * sizeof(U16) ~ 8 MB
            maxsamples = 2^29; % 1 GB
            
            %make chunk size smaller as long as allocation fails
            %bigger chunks are much faster to upload but are not as easy to
            %create for the operating system
            status = -1;
            while status~=0
                chunksamples = 2^chunkexponent;
                
                status = calllib('PXDACMemoryManager','initializeU16',obj.handle,uint32(maxsamples),uint32(chunksamples));
                chunkexponent = chunkexponent-1;
                
                if chunkexponent == 0
                    error('can not allocate enouch DMA buffers for PXDAC.');
                end
            end
            fprintf('Initialized memory manager with 2^%d samples per chunk.\n', chunkexponent);
            
            
            fprintf('%s: successfully connected to %s (your mother) with serial number %d\n',id,class(obj),obj.serialNumber);
        end
         
        registerPulses(self,grp);
        
    end
    
    methods
        function delete(self)
            fprintf('Deleting PXDAC %s\n',self.identifier);
            
            status = calllib('PXDACMemoryManager','free_memory');
            if status
                warning('Failure "%s" while freeing PXDAC manager memory.',PXDAC.statusToErrorMessage(status));
            end
            
            fprintf('Disconnecting from device...\n')
            status = calllib('PXDAC4800_64','DisconnectFromDeviceXD48',self.handle);
            if status
                warning('Error "%s" while disconnecting from device %d',PXDAC.statusToErrorMessage(status),self.serialNumber);
            else
                fprintf('Successfully disconnected from %d\n',self.serialNumber);
            end
        end
        
        function setChannelMask(self,mask)
            if mask~=self.activeChannelMask
                warning('Channel mask changed. All stored pulsegroups will be removed.');
                self.clearBoardMemory();
                self.activeChannelMask = mask;
                self.library('SetActiveChannelMaskXD48',self.handle,mask);
            end
        end
        
        %free board memory to have enough space and return start position
        [start, index] = freeEnoughMemory(self,requiredize)
        
        uploadPulsegroupToCard(self,name)
            
            
        
        
        
        function setActivePulsegroup(self,pulsegroupName)
            if isKey(self.storedPulsegroups,pulsegroupName)
                self.activePulsegroup = pulsegroupName;
                if isempty(self.storedPulsegroups(pulsegroupName).start)
                    warning('The pulsegroup %s is set active, but is not in PXDAC memory. Make sure to upload the pulsegroup before starting playback.',sequenceName);
                end
            else
                error('Can not activate pulsegroup "%s". Since it is not known.',sequenceName);
            end
        end
        
        
        % implemented abstact methods
        %remove this pulsegroup from memory and forget about it
        function removePulseGroup(self,name)
            if strcmp(self.activePulsegroup,name)
                self.activePulsegroup = 'none';
            end
            self.storedPulsegroups.remove(name);
        end
        
        %update the changed pulses
        function updatePulseGroup(self,grpdef)
            error('notimplemented');
        end
        
        %wait for trigger
        function arm(self)            
            self.waitForTrigger();
        end
        
        %this function is for debugging purposes
        function issueSoftwareTrigger(self)
            error('not implemented');
        end
        
        
        function clearBoardMemory(self)
            if ~isempty(self.storedPulsegroups)
                self.storedPulsegroups(1:end).start = [];
            end
            self.activePulsegroup = 'none';
            self.activeChannelMask = uint16(0);
        end
        
        
        function waitForTrigger(self)
            
            if strcmp(self.activePulsegroup,'none')
                error('No pulsegroup activated on %s.',self.identifier);
            elseif ~isKey(self.storedPulsegroups,self.activePulsegroup)
                error('The pulsegroup %s is not known to %s although it is set as active pulsegroup. This hints a bug.',self.activePulsegroup,self.identifier);
            end
            
            self.uploadPulsegroupToCard(self.activePulsegroup);
            
            pulsegroup = self.storedPulsegroups(self.activePulsegroup);
            if pulsegroup.repetitions == Inf
                pulsegroup.repetitions = 0;
            end
            
            status = uint32(0);
            self.library('GetFPGAStatusXD48',...
                self.handle,...
                status);
            if status > 0
                fprintf('Recieved suspicious status from card.');
                if bitget(status,7)
                    error('Data playback in progress.')
                end
            end
            
            self.library('SetPlaybackClockSourceXD48',self.handle,0);
            self.library('SetClockDivider1XD48',self.handle,12);
            self.library('SetClockDivider2XD48',self.handle,1);
            
            
            self.library('SetExternalTriggerEnableXD48',...
                self.handle,int32(1));
            
            self.library('SetTriggerModeXD48',...
                self.handle,...
                int32(2));% XD48TRIGMODE_SINGLE_SHOT (2) Trigger runs memory data once; subsequent triggers ignored
            
            
            self.library('BeginRamPlaybackXD48',...
                self.handle,...
                uint32(self.acitveSequence.start),...
                uint32(self.acitveSequence.length),...
                uint32(self.acitveSequence.length*self.acitveSequence.repetitions));
        end
        
        function setOutputVoltage(self,channel,ppVoltage)
            x = (ppVoltage-self.allowedVoltageRange(1))/(self.allowedVoltageRange(2)-self.allowedVoltageRange(1));
            if x > 1
                error('Voltage %d to large',ppVoltage);
            elseif x < 0
                error('Voltage %d to small',ppVoltage);
            end
            
            
            self.library(sprintf('SetOutputVoltageCh%iXD48',channel),...
                self.handle,...
                int32(x*1023));
        end
        
        function ppVoltage = getOutputVoltage(self,channel)
            %output voltage int
        	ppVoltageInt = calllib('PXDAC4800_64',sprintf('GetOutputVoltageCh%iXD48',channel),...
                self.handle,0);
            
            %convert to double
            temp = libpointer('double',zeros(1,1));
            self.library('GetOutputVoltageRangeVoltsXD48',...
                ppVoltageInt,...
                temp,self.handle)
            ppVoltage = temp.Value;
        end
        
        function playbackInProgress = isPlaybackInProgress(self)
            libReturn = calllib('PXDAC4800_64','IsPlaybackInProgressXD48', self.handle);
            if (libReturn < 0)
                error(statusToErrorMessage(libReturn));
            end
            playbackInProgress = (libReturn > 0);
        end
    end
    
    methods (Static)
        function errormsg = statusToErrorMessage(status)
            errormsg = calllib('PXDAC4800_64','GetErrorMessXD48',...
                status,...
                libpointer('stringPtr'),0,libpointer('voidPtr',[]));
            error(errormsg);
        end
        
        function testStatus(status)
            if status < 0
                error(statusToErrorMessage);
            end
        end
        
        function library(fn, varargin)
            PXDAC.testStatus( calllib('PXDAC4800_64', fn, varargin{:}) );
        end
    end
end