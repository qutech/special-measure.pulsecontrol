classdef RSAIOTestSetup < DefaultTestSetup
    
    properties (Constant, GetAccess = private)
        test_start = 400;
        test_end = 600;
        test_period = 1000;
        test_iterations = 100;
        test_random_points = 20; % must be < test_end - test_start
    end
    
    methods (Access = public)
        
        function obj = RSAIOTestSetup()
            obj = obj@DefaultTestSetup(RSAIOTestSetup.test_iterations * RSAIOTestSetup.test_period, 1, 1e-4);
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
            
            self.dac.configureMeasurement(samplesInPeriod, self.test_iterations, 1, 8 + inputChannel);
        end
        
        function initPulseGroup(self)
            dt = 1; % us
            
            rng(42);

            randomValues = rand(1, self.test_random_points) * 2 - 1;            

            pulse.data.pulsetab = zeros(2, 4 + self.test_random_points);
            
            pulse.data.pulsetab(1,:) = [0, self.test_start - dt, ...
                linspace(self.test_start, self.test_end, self.test_random_points), ...
                self.test_end + dt, self.test_period];            
            
            pulse.data.pulsetab(2,:) = [-randomValues(1), -randomValues(1), ...
                randomValues, ...
                -randomValues(end), -randomValues(end)];

            pulse.name = 'RSAIOTestPulse';

            self.pulsegroup.pulses = plsreg(pulse);
            self.pulsegroup.chan = 1;
            self.pulsegroup.nrep = self.test_iterations;
            self.pulsegroup.name = 'RSAIOTestPulseGroup';
            self.pulsegroup.ctrl = 'notrig';
            
            plsdefgrp(self.pulsegroup);
            
            mainPulse.data.pulsetab = zeros(2, self.test_random_points);
            mainPulse.data.pulsetab(1, :) = linspace(0, self.test_end - self.test_start, self.test_random_points);
            mainPulse.data.pulsetab(2, :) = randomValues;
            
            mainPulse = plstowf(mainPulse);
            self.expectedData = mainPulse.data.wf;
            
            %elementalPulse.data.wf
            % TODO: calculate expected measurement signal
        end

        
    end
    
end

