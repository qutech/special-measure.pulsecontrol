classdef TestSetup
    
    properties(SetAccess = private, GetAccess = protected)
        duration;
        inputChannel;
        errorThreshold; % tolerated RMS error threshold in Volts; value strongly depends on the test
    end
    
    methods(Access = protected)
        function obj = TestSetup(duration, inputChannel, errorThreshold)
            obj.duration = duration;
            obj.inputChannel = inputChannel;
            obj.errorThreshold = errorThreshold;
        end
    end
    
    methods(Abstract, Access = public)        
        init(self); % initialize the test
        success = run(self); % run the test and return whether or not it was successful
    end
    
    methods(Abstract, Access = protected)
        
        initVAWG(self); % initialize the arbitrary waveform generator
        
        initDAC(self); % initialize the data acquisition device
        
        initPulseGroup(self); % initializes pulses and calculates expected data
        
        success = evaluate(self);
        
    end
        
end

