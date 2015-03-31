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
            obj.lastload = -Inf;
            obj.repetitions = [];
        end
    end
end