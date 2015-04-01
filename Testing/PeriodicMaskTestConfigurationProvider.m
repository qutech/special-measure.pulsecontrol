classdef PeriodicMaskTestConfigurationProvider < TestConfigurationProvider
    
    properties (SetAccess = protected, GetAccess = protected)
        % TODO: does period always need to be a potency of 2?
        mask = struct( ...
            'begin',    400, ...
            'end',      600, ...
            'period',   1000,...
            'type',     'Periodic Mask' ...
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
            self.mask.hwChannel = inputChannel;
        end
        
    end
    
end

