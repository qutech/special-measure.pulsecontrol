classdef TestPulseBuilder < handle
    
    properties (Constant, Abstract, GetAccess = public)
        meanErrorThreshold;
        singleErrorThreshold;
        dacOperation;
    end
    
    properties (Constant, Abstract, GetAccess = protected)
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
        createPulse(self, mask, repetitions);
    end
    
    methods (Access = protected)
        
        function self = TestPulseBuilder()
            self.reset();
        end
        
    end
    
    methods (Access = public)
        
        function addPulse(self, mask, repetitions)
            self.pulseCount = self.pulseCount + repetitions * mask.period;
            self.createPulse(mask, repetitions);
        end
        
        function reset(self)
            self.pulseGroup = self.pulseGroupPrototype;
            self.pulseCount = 0;
            self.expectedData = [];
        end
    end
    
end

