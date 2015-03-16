classdef TestSetup
    
    properties(SetAccess = private, GetAccess = protected)
        duration;
        inputChannel;
        meanErrorThreshold; % tolerated RMS error threshold in Volts; value strongly depends on the test
        singleErrorThreshold; % tolerated single maximum error
    end
    
    methods(Access = protected)
        function obj = TestSetup(duration, inputChannel, meanErrorThreshold, singleErrorThreshold)
            obj.duration = duration;
            obj.inputChannel = inputChannel;
            obj.meanErrorThreshold = meanErrorThreshold;
            obj.singleErrorThreshold = singleErrorThreshold;
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

