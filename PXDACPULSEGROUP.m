classdef PXDACPULSEGROUP < AWGPULSEGROUP
    properties
        start = [];
        totalByteSize = [];
        lastMemoryUpdate = -Inf;
        
        %if not enough onboard memory -> the oldest one will be deleted
        lastActivation = -Inf;
        
        % equivalent to grpdef.pulses
        waveformArray = PXDACPULSE.empty(0,0);
        
        %equivalent to grpdef.pulseind and grpdef.nrep
        pulseSequence = repmat(struct('index',[],'nrep',[]),0,0);
    end
    
    methods
        function obj = PXDACPULSEGROUP(name)
            obj = obj@AWGPULSEGROUP(name);
        end
    end
end