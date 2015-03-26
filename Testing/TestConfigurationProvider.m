classdef TestConfigurationProvider < handle
    
    properties (SetAccess = private, GetAccess = public)
        inputChannel = 1;
        meanErrorThreshold;
        singleErrorThreshold;
    end
    
    properties (SetAccess = private, GetAccess = protected)
        pulseBuilder;
    end
    
    properties (Abstract, GetAccess = protected)
        mask;
    end
    
    methods (Abstract, Access = protected)
        computePulseGroup(self);
    end
    
    methods (Access = public)
        
        function self = TestConfigurationProvider(inputChannel, pulseBuilder)
            assert(isa(pulseBuilder, 'TestPulseBuilder'), 'pulseBuilder must be an instance of TestPulseBuilder!');
            assert(isnumeric(inputChannel) && inputChannel > 0, 'inputChannel must be a positive integer value!');
            
            self.pulseBuilder = pulseBuilder;
            self.inputChannel = inputChannel;
            self.meanErrorThreshold = self.pulseBuilder.meanErrorThreshold;
            self.singleErrorThreshold = self.pulseBuilder.singleErrorThreshold;
        end
        
        function createPulseGroup(self)
            self.pulseBuilder.reset();
            self.computePulseGroup();
            plsdefgrp(self.pulseBuilder.pulseGroup, true); % Second argument suppresses file overwrite user query
        end
        
        function pulseGroup = getPulseGroup(self)
            pulseGroup = self.pulseBuilder.pulseGroup;
        end
        
        function expectedData = getExpectedData(self)
            expectedData = self.pulseBuilder.expectedData;
        end
        
        function dac = createDAC(self)
            switch (self.pulseBuilder.dacOperation)
                case 'raw'
                    operation = self.inputChannel;
                case 'ds'
                    operation = self.inputChannel + 4;
                case 'rsa'
                    operation = self.inputChannel + 8;
                otherwise
                    error('DAC operation %s unknown', self.pulseBuilder.dacOperation);
            end
            
            dac = ATS9440(1);
            dac.samprate = 100e6;
            samplesInPeriod = self.mask.period * dac.samprate / 1e6;
            dac.masks = { self.mask };
            dac.configureMeasurement(samplesInPeriod, self.pulseBuilder.pulseCount, 1, operation);
        end
        
    end
    
end

