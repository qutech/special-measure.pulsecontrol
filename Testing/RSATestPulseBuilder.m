classdef RSATestPulseBuilder < TestPulseBuilder
    
    properties (Constant, GetAccess = public)
        meanErrorThreshold = 1e-4;
        singleErrorThreshold = 1e-3;
        dacOperation = 'rsa';
    end
    
    properties (Constant, GetAccess = protected)
        pulseGroupPrototype = struct( ...
                'pulses', [], ...
                'nrep', [], ...
                'name', 'RSATestPulseGroup', ...
                'chan', 1, ...
                'ctrl', 'notrig' ...
            );
        
        voltageHoldDuration = 20;
    end
    
    properties (SetAccess = private, GetAccess = private)
        readoutDuration = 0;
        readoutVoltages = [];
        period = 0;
    end
    
    methods (Access = public)
        
        function self = RSATestPulseBuilder(voltageRange)
            self = self@TestPulseBuilder(voltageRange);
            rng(42);
        end
        
        function reset(self)
            reset@TestPulseBuilder(self);
            self.readoutDuration = 0;
            self.readoutVoltages = [];
            self.period = 0;
        end
        
    end
    
    methods (Access = protected)
        
        function createPulse(self, mask, repetitions)
            dt = 1; % us
            
            if (self.readoutDuration == 0)
                self.readoutDuration = mask.end - mask.begin;
            end
            
            if (self.period == 0)
                self.period = mask.period;
            end
            
            assert(self.period == mask.period, 'Period of mask deviates from previous values.');
            assert(self.readoutDuration == mask.end - mask.begin, 'Duration of readout window in mask deviates from previous values!');
            assert(self.readoutDuration >= 0, 'Duration of readout window in mask was less than zero!');
            assert(mask.begin == 0 || mask.begin >= dt, 'Could not compute pulse because begin of readout window was to close to zero.');
            assert(mask.end == mask.period || mask.end <= mask.period - dt, 'Could not compute pulse because end of readout windows was to close to period.');
            
            if (isempty(self.readoutVoltages))
                
                readoutVoltageCount = floor(self.readoutDuration / self.voltageHoldDuration) + 1;
                self.readoutVoltages = self.convertToVoltageRange(rand(1, readoutVoltageCount));
                
                readoutPulse.data.pulsetab = [linspace(0, self.readoutDuration, readoutVoltageCount); self.readoutVoltages];
                
                readoutPulse = plstowf(readoutPulse);
                self.expectedData = readoutPulse.data.wf;
            end
            
            readoutVoltageTable = [linspace(mask.begin, mask.end, size(self.readoutVoltages, 2)); self.readoutVoltages];
            
            preReadoutVoltages = [];
            postReadoutVoltages = [];
            if (mask.begin > 0)
                preReadoutVoltages =  [ 0,                        mask.begin - dt; ...
                                        -self.readoutVoltages(1), -self.readoutVoltages(1) ];
            end
            if (mask.end < mask.period)
                postReadoutVoltages = [ mask.end + dt,              mask.period; ...
                                        -self.readoutVoltages(end), -self.readoutVoltages(end) ];
            end
            
            pulse.data.pulsetab = [preReadoutVoltages readoutVoltageTable postReadoutVoltages];
            pulse.name = sprintf('RSAIOTestPulse%i', self.pulseCount);
            
            self.pulseGroup.pulses(end + 1) = plsreg(pulse);
            self.pulseGroup.nrep(end + 1) = repetitions;
            
        end
        
    end
    
end

