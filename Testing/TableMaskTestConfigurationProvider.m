classdef TableMaskTestConfigurationProvider < TestConfigurationProvider
    
    properties (SetAccess = protected, GetAccess = protected)
        % TODO: does period always need to be a potency of 2?
        mask = struct( ...
            'type',     'Table Mask', ...
            'begin',    400 + floor(linspace(0, 200, 100)), ...
            'end',      600 + floor(linspace(0, 200, 100)), ...
            'period',   1000 ...
        );
    end
    
    methods (Access = protected)
        
        function computePulseGroup(self)
            currentMask = self.mask;
            for i = 1:numel(self.mask.begin)
                currentMask.begin = self.mask.begin(i);
                currentMask.end = self.mask.end(i);
                self.pulseBuilder.addPulse(currentMask, 1);
            end
        end
        
    end
    
    methods (Access = public)
        
        function self = TableMaskTestConfigurationProvider(inputChannel, pulseBuilder, mask)
            self = self@TestConfigurationProvider(inputChannel, pulseBuilder);
            if (nargin >= 3)
                assert(isfield(mask, 'type'), 'mask must be a table mask!');
                assert(strcmp(mask.type, 'Table Mask'), 'mask must be a table mask!');
                assert(numel(mask.begin) == numel(mask.end), 'begin and end table dimensions of mask are not equal!');
                self.mask = mask;
            end
            self.mask.hwChannel = inputChannel;
        end
        
    end
    
end

