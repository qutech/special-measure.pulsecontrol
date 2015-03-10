classdef RSAIOTestSetup < DefaultTestSetup
    
    properties (GetAccess = public, SetAccess = public)
        test_start = 400;
        test_end = 600;
        test_period = 1000;
        test_iterations = 100;
        test_random_points = 20; % must be < test_end - test_start
    end
    
    methods (Access = public)
        
        function obj = RSAIOTestSetup()
            obj = obj@DefaultTestSetup();
            obj.duration = obj.test_iterations * obj.test_period;
        end
        
    end
    
    methods (Access = protected)
        
       function initDAC(self)
            error('TODO: Must configure DAC accordingly.');
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
                randomValues(1:end), ...
                -randomValues(end), -randomValues(end)];

            pulse.name = 'RSAIOTestPulse';

            self.pulsegroup.pulses = plsreg(pulse);
            self.pulsegroup.chan = 1;
            self.pulsegroup.nrep = self.test_iterations;
            self.pulsegroup.name = 'RSAIOTestPulseGroup';
            self.pulsegroup.ctrl = 'notrig';
            
            plsdefgrp(self.pulsegroup);
        end
        
        function evaluate(self, measured)
            pls = plstowf(self.pulsegroup.pulses);
            plot(pls.data.wf);
        end 
        
    end
    
end

