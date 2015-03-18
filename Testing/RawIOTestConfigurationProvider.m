classdef RawIOTestConfigurationProvider < TestConfigurationProvider
    
    properties (Constant, GetAccess = protected)
        mask = struct( ...
            'begin',    0, ...
            'end',      10000, ...
            'period',   10000 ...
        );
    end
    
    methods (Access = protected)
        
        function computePulseGroup(self)
            self.pulseBuilder.addPulse(self.mask, 1);
        end
        
    end
    
    methods (Access = public)
        
        function self = RawIOTestConfigurationProvider(inputChannel, pulseBuilder)
            self = self@TestConfigurationProvider(inputChannel, pulseBuilder);
        end
    end
    
end

