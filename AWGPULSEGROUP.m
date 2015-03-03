% pulsegroup representation in AWG driver
classdef AWGPULSEGROUP < matlab.mixin.Heterogeneous & handle
    properties
        name;
        lastload = -Inf;
        repetitions = [];
    end
    
    methods
        function obj = AWGPULSEGROUP(name)
            obj.name = name;
        end
    end
end