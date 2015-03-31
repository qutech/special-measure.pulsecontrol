classdef TestPulseBuilder < handle
    % TestPulseBuilder An abstract base for classes that provide pulse
    % groups for hardware IO tests.
    %
    % Subclasses provide functionality to construct a pulse group and the
    % expected data to test a specific DAC operation according to provided
    % readout masks.
    % The following properties/methods need to be implemented:
    % - meanErrorThreshold
    % - singleErrrorThreshold
    % - dacOperation ('raw', 'ds' or 'rsa')
    % - pulseGroupPrototype
    % - createPulse
    
    properties (Constant, Abstract, GetAccess = public)
        meanErrorThreshold;
        singleErrorThreshold;
        dacOperation;
    end
    
    properties (Constant, Abstract, GetAccess = protected)
        % A prototype for an empty pulse group. Used in the reset
        % operation.
        pulseGroupPrototype;
    end
    
    properties (SetAccess = private, GetAccess = public)
        pulseCount = 0;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        pulseGroup;
        expectedData;
    end
    
    methods (Abstract, Access = protected)
        % Creates a single pulse and expected data according to the mask
        % and the DAC operation and adds the created pulse to the pulse
        % pulse group in construction. Called by addPulse().
        createPulse(self, mask, repetitions);
    end
    
    methods (Access = protected)
        
        function self = TestPulseBuilder()
            self.reset();
        end
        
    end
    
    methods (Access = public)
        
        % addPulse adds a pulse to the constructed pulse group according to
        % the mask and alters the expected data accordingly. The create
        % pulse is guaranteed to be as long as mask.period.
        function addPulse(self, mask, repetitions)
            self.pulseCount = self.pulseCount + repetitions * mask.period;
            self.createPulse(mask, repetitions);
        end
        
        % reset resets the currently constructed pulse group and expected
        % data.
        function reset(self)
            self.pulseGroup = self.pulseGroupPrototype;
            self.pulseCount = 0;
            self.expectedData = [];
        end
    end
    
end

