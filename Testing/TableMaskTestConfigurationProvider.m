classdef TableMaskTestConfigurationProvider < TestConfigurationProvider
    % TableMaskTestConfigurationProvider Provides a test configuration for
    % a table mask.
    %
    % The default mask has a period of 1000 and 100 readout windows:
    % [400,600], [402, 602], .... [600, 800]. The default mask can be
    % replaced by any other table mask in the constructor (optional).
    % The constructed test pulse group is contains the according amount of
    % pulses in sequence.
    
    properties (GetAccess = protected)
        mask = struct( ...
            'type', 'Table Mask', ...
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
        end
        
    end
    
end

