classdef RandomTestPulseBuilder < TestPulseBuilder
    
    properties (Constant, GetAccess = public)
        meanErrorThreshold = 1e-3;
        singleErrorThreshold = 0.5e-2;
        dacOperation = 'raw';
    end
    
    properties (Constant, GetAccess = protected)
        pulseGroupPrototype = struct( ...
                'pulses', [], ...
                'nrep', [], ...
                'name', 'RandomTestPulseGroup', ...
                'chan', 1, ...
                'ctrl', 'notrig' ...
            );
        
        voltageHoldDuration = 100;
    end
    
    methods (Access = public)
        
        function self = RandomTestPulseBuilder(voltageRange)
            self = self@TestPulseBuilder(voltageRange);
            rng(42);
        end
        
    end
    
    methods (Access = protected)
        
        function createPulse(self, mask, repetitions)
            readoutDuration = mask.period;
            voltagesAmount = ceil(readoutDuration / self.voltageHoldDuration);
            
            randomVoltages = self.convertToVoltageRange(rand(1, voltagesAmount));
            pulse.data.pulsetab = zeros(2, voltagesAmount);
            pulse.data.pulsetab(1, :) = linspace(mask.begin, mask.end, voltagesAmount);
            pulse.data.pulsetab(2, :) = randomVoltages;
            
            pulse.name = sprintf('RandomTestPulse%i', self.pulseCount);
            
            self.pulseGroup.pulses(end + 1) = plsreg(pulse);
            self.pulseGroup.nrep(end + 1) = repetitions;
            
            p = plstowf(pulse);
            for i = 1:repetitions
                self.expectedData = [self.expectedData, p.data.wf];
            end
        end
        
    end
    
end

