classdef TestConfigurationProvider < handle
    % TestConfigurationProvider An abstract base for classes that provide
    % a readout mask for hardware IO Tests and construct a pulse group
    % using a TestPulseBuilder instance accordingly.
    %
    % Subclasses need to implement the following properties/methods:
    % - mask
    % - computePulseGroup
    
    properties (SetAccess = private, GetAccess = public)
        inputChannel = 1;
        meanErrorThreshold; % Value copied from pulseBuilder object in constructor
        singleErrorThreshold; % Value copied from pulseBuilder object in constructor
    end
    
    properties (SetAccess = private, GetAccess = protected)
        pulseBuilder;
    end
    
    properties (Abstract, GetAccess = protected)
        % The readout mask used in the DAC (periodic or table mask).
        mask;
    end
    
    methods (Abstract, Access = protected)
        % Constructs the pulse group. Must not use plsdefgrp(..). Called by
        % createPulseGroup().
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
        
        % Create the pulse group using the provider TestPulseBuilder
        % instance with the internally implemented pulse group construction
        % algorithm.
        function createPulseGroup(self)
            self.pulseBuilder.reset();
            self.computePulseGroup();
            plsdefgrp(self.pulseBuilder.pulseGroup);
        end
        
        % Obtains the created pulse group. Make sure to call
        % createPulseGroup first.
        function pulseGroup = getPulseGroup(self)
            pulseGroup = self.pulseBuilder.pulseGroup;
        end
        
        % Obtains the expected data. Make sure to call createPulseGroup
        % first.
        function expectedData = getExpectedData(self)
            expectedData = self.pulseBuilder.expectedData;
        end
        
        % Constructs and returns the DAC object for the test initialized
        % with the specific readout mask for the test.
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

