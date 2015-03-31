classdef PeriodicMaskTestConfigurationProvider < TestConfigurationProvider
    % PeriodicMaskTestConfigurationProvider Provides a test configuration for
    % a periodic mask.
    %
    % The default mask has a period of 1000 and a readout window from 400
    % to 600. It can be replaced by any other periodic mask in the
    % constructor (optional).
    % The test pulse group is constructed by creating a given number of
    % pulses with the same mask. This number of iterations defaults to 100
    % but can be changed via the class constructor (optional).
    
    properties (GetAccess = protected)
        mask = struct( ...
            'begin',    400, ...
            'end',      600, ...
            'period',   1000 ...
        );
        iterations = 100;
    end
    
    methods (Access = protected)
        
        function computePulseGroup(self)
            for i = 1:self.iterations
                self.pulseBuilder.addPulse(self.mask, 1);
            end
        end
        
    end
    
    methods (Access = public)
        
        function self = PeriodicMaskTestConfigurationProvider(inputChannel, pulseBuilder, mask, iterations)
            self = self@TestConfigurationProvider(inputChannel, pulseBuilder);
            if (nargin >= 3)
                assert(~isfield(mask, 'type') || ~strcmp(mask.type, 'Table Mask'), 'mask must not be a table mask!');
                self.mask = mask;
            end
            if (nargin == 4)
                assert(isnumeric(iterations) && iterations > 0, 'iterations must be a positive integer value!');
                self.iterations = iterations;
            end
        end
        
    end
    
end

