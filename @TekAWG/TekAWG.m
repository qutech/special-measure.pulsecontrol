classdef TekAWG < AWG
    
    properties (GetAccess = public, SetAccess = protected)
        handle;
        
        triglen = 1000;
        zeropls; % length of zeropulses stored on the awg
        
        zerochan; % !!! functinoality not clear

        
        seqpulses = []; % !!! functinoality not clear
        
        waveforms = {};
    end
    
    methods
        % constructor
        function obj = TekAWG(id,handle)
            obj = obj@AWG(id);
            obj.handle = handle;
            
            class(obj);
            
            obj.clk = 1.2e9;
            
            obj.zerochan = ones(1,obj.nChannels);
            %check for global awgdata
        end
        
        function last = lastFreeSequenceLine(self)
            if isempty(self.storedPulsegroups)
                last = 1;
                return;
            end
            
            last = self.storedPulsegroups(end).seqind + sum(self.storedPulsegroups(end).nline);
        end
        
        
        % implemented abstact methods
        %make this pulsegroup playable by AWG
        addPulseGroup(self,grpdef);
        
        %remove this pulsegroup from memory and forget about it
        removePulseGroup(self,name);
        
        %update the changed pulses
        updatePulseGroup(self,grpdef);
        
        %wait for trigger
        arm(self);
        
        %this function is for debugging purposes
        issueSoftwareTrigger(self);
        
        syncwaveforms(self)
        
        loadwfm(self,data, marker, name, chan,define)
    end
end