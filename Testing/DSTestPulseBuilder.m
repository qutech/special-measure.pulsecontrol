classdef DSTestPulseBuilder < TestPulseBuilder
    
    properties (Constant, GetAccess = public)
        meanErrorThreshold = 1e-4;
        singleErrorThreshold = 1e-3;
        dacOperation = 'ds';
    end
    
    properties (Constant, GetAccess = protected)
        pulseGroupPrototype = struct( ...
                'pulses', [], ...
                'nrep', [], ...
                'name', 'DownsamplingTestPulseGroup', ...
                'chan', 1, ...
                'ctrl', 'notrig' ...
            );
        
        voltageHoldDuration = 100;
    end
    
    methods (Access = public)
        
        function self = DSTestPulseBuilder(voltageRange)
            self = self@TestPulseBuilder(voltageRange);
            rng(42);
        end
        
    end
    
    methods (Access = protected)
        
        function createPulse(self, mask, repetitions)
            dt = 1; % us
            
            readoutDuration = mask.end - mask.begin;
            
            assert(readoutDuration >= 0, 'Duration of readout window in mask was less than zero!');
            assert(mask.begin == 0 || mask.begin >= dt, 'Could not compute pulse because begin of readout window was to close to zero.');
            assert(mask.end == mask.period || mask.end <= mask.period - dt, 'Could not compute pulse because end of readout windows was to close to period.');
            
            randomVoltage = self.convertToVoltageRange(rand(1, 1));
            
            readoutVoltages = [ mask.begin,     mask.end; ...
                                randomVoltage,  randomVoltage ];
            
            preReadoutVoltages = [];
            postReadoutVoltages = [];
            if (mask.begin > 0)
                preReadoutVoltages =  [ 0,              mask.begin - dt; ...
                                        -randomVoltage, -randomVoltage ];
            end
            if (mask.end < mask.period)
                postReadoutVoltages = [ mask.end + dt,  mask.period; ...
                                        -randomVoltage, -randomVoltage ];
            end
            
            pulse.data.pulsetab = [preReadoutVoltages readoutVoltages postReadoutVoltages];
            pulse.name = sprintf('DSIOTestPulse%i', self.pulseCount);
            
            self.pulseGroup.pulses(end + 1) = plsreg(pulse);
            self.pulseGroup.nrep(end + 1) = repetitions;
            
            for i = 1:repetitions
                self.expectedData = [self.expectedData, randomVoltage]; 
            end
            
        end
        
    end
    
end

