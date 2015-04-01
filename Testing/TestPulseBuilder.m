classdef TestPulseBuilder < handle & matlab.mixin.Heterogeneous
    
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
        voltageRange = [-0.5 0.5];
    end
    
    properties (SetAccess = protected, GetAccess = public)
        pulseGroup;
        expectedData;
    end
    
    methods (Abstract, Access = protected)
        createPulse(self, mask, repetitions);
    end
    
    methods (Access = protected)
        
        function self = TestPulseBuilder(voltageRange)
            self.voltageRange = voltageRange;
            self.reset();
        end
        
    end
    
    methods (Access = public)
        
        function addPulse(self, mask, repetitions)
            self.pulseCount = self.pulseCount + repetitions;
            self.createPulse(mask, repetitions);
        end
        
        function reset(self)
            self.pulseGroup = self.pulseGroupPrototype;
            self.pulseCount = 0;
            self.expectedData = [];
        end
    end
    
    methods (Access = protected)
        
        function y = convertToVoltageRange(self, x)
            peakToPeakVoltage = self.voltageRange(2) - self.voltageRange(1);
            y = x .* peakToPeakVoltage + self.voltageRange(1);
        end
    end
    
end

