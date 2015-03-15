classdef DefaultTestSetup < TestSetup

    properties(GetAccess = protected, SetAccess = protected)
        pulsegroup;
        dac;
        vawg;
    end
    
    properties(GetAccess = public, SetAccess = protected)
        expectedData = [];
        measuredData = [];
    end
    
    methods (Access = public)
        
        function obj = DefaultTestSetup(duration, inputChannel, errorThreshold)
            obj = obj@TestSetup(duration, inputChannel, errorThreshold);
        end
        
        function init(self)
            % pulse to test
            self.initPulseGroup();

            % awg to test
            self.initVAWG();

            self.vawg.add(self.pulsegroup.name);
            self.vawg.setActivePulseGroup(self.pulsegroup.name);
            
            % DAQ card
            self.initDAC();

            self.vawg.arm();
        end
        
        function success = run(self)
            self.dac.issueTrigger();
    
            while self.vawg.playbackInProgress()
                pause(1);
                fprintf('Waiting for playback to finish...\n');
            end

            self.measuredData = self.dac.getResult(self.inputChannel);
            success = self.evaluate();
        end
        
    end
    
    methods (Access = protected)
        
        function initVAWG(self)
            self.vawg = VAWG();
    
            awg = PXDAC_DC('messrechnerDC',1);
            awg.setOutputVoltage(1,1);

            self.vawg.addAWG(awg);
            self.vawg.createVirtualChannel(awg,1,1);
        end
        
        function initDAC(self)
            self.dac = ATS9440(1);
    
            self.dac.samprate = 100e6; %samples per second
            sis = self.duration * self.dac.samprate / 1e6; % samples in scanline

            self.dac.useAsTriggerSource();
            
            self.dac.configureMeasurement(1, sis, 1, self.inputChannel);
        end
        
        function initPulseGroup(self)
            N = 1000;
            rng(42);

            pulse.data.pulsetab = zeros(2, N);
            pulse.data.pulsetab(1,:) = linspace(1, self.duration, N);
            pulse.data.pulsetab(2,:) = rand(1, N) * 2 - 1;

            pulse.name = 'hardwareTestPulse';

            self.pulsegroup.pulses = plsreg(pulse);
            self.pulsegroup.nrep = 1;
            self.pulsegroup.name = 'hardwareTestPulseGroup';
            self.pulsegroup.chan = 1;
            self.pulsegroup.ctrl = 'notrig';

            plsdefgrp(self.pulsegroup);
            
            p = plstowf(pulse);
            self.expectedData = p.data.wf;
        end
        
        function success = evaluate(self)
           err = self.measuredData - self.expectedData; % error signal
           rms = std(err,0); % average error per sample
           success = rms < self.errorThreshold; 
        end
        
    end
    
end

