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
        add(self,pulsegroup)
        
        val = control(self,cntrl, chans)

        erase(self,groups,options)
        
        syncwaveforms(self)
        
        upload(self,name)
        
        
        rm(self,grp, ctrl)
        
        loadwfm(self,data, marker, name, chan,define)
    end
end