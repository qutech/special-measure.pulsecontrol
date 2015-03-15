classdef DSIOTestSetup < DefaultTestSetup
    
    properties (Constant, GetAccess = private)
        test_start = 400;
        test_end = 600;
        test_period = 1000;
        test_iterations = 100;
    end
    
    methods (Access = public)
        
        function obj = DSIOTestSetup()
            obj = obj@DefaultTestSetup(DSIOTestSetup.test_iterations * DSIOTestSetup.test_period, 1, 1e-4);
        end
        
    end
    
    methods (Access = protected)
        
        function initDAC(self)
            mask = struct('begin', self.test_start, 'end', self.test_end, 'period', self.test_period, 'hwChannel', self.inputChannel);
            
            self.dac = ATS9440(1);
    
            self.dac.samprate = 100e6; %samples per second
            samplesInPeriod = self.test_period * self.dac.samprate / 1e6;
            
            self.dac.masks = { mask };

            self.dac.useAsTriggerSource();
            
            self.dac.configureMeasurement(samplesInPeriod, self.test_iterations, 1, 4 + inputChannel);
        end
        
        function initPulseGroup(self)
            dt = 1; % us
            
            rng(42);

            randomValues = rand(1, self.test_iterations) * 2 - 1;
            self.expectedData = randomValues;
            
            self.pulsegroup.pulses = zeros(1,self.test_iterations);
            self.pulsegroup.chan = 1;
            self.pulsegroup.name = 'DSIOTestPulseGroup';
            self.pulsegroup.ctrl = 'notrig';
            
            for i = 1:self.test_iterations
                randomValue = randomValues(i);
                pulse.data.pulsetab = zeros(2, 6);
                pulse.data.pulsetab(1,:) = [0, self.test_start - dt, ...
                    self.test_start, self.test_end, self.test_end + dt, ...
                    self.test_period];
                pulse.data.pulsetab(2,:) = [-randomValue, -randomValue, ...
                    randomValue, randomValue, -randomValue, ...
                    -randomValue];
                pulse.name = sprintf('DSIOTestPulse%i', i);
                self.pulsegroup.pulses(i) = plsreg(pulse);
            end            

            plsdefgrp(self.pulsegroup);
        end
        
    end
    
end

