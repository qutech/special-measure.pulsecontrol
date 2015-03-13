classdef TestSetup

    properties(SetAccess = protected, GetAccess = protected)
        duration;
        inputChannel;
    end
    
    properties(Abstract, SetAccess = protected, GetAccess = protected)
        expectedData; % expected measurement values if everything works as intended
    end
    
    properties(Abstract, SetAccess = protected, GetAccess = public)
        errorThreshold; % tolerated RMS error threshold in Volts; value strongly depends on the test
    end
    
    methods(Abstract, Access = public)
        init(self); % initialize the test
        success = run(self); % run the test and return whether or not it was successful
    end
    
    methods(Abstract, Access = protected)
        
        initVAWG(self); % initialize the arbitrary waveform generator
        
        initDAC(self); % initialize the data acquisition device
        
        initPulseGroup(self); % initializes pulses and calculates expected data
        
    end
    
    methods(Access = protected)
        function success = evaluate(self, measured)
           err = measured - self.expectedData; % error signal
           rms = std(err,0); % average error per sample
           success = rms < self.errorThreshold; 
        end
    end
        
end

