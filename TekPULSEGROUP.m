classdef TekPULSEGROUP < AWGPULSEGROUP
    properties
        %index of sequence start
        seqind = [];
        
        %number of pulses and usetrig
        npulse = [0 0];
        
        %
        nline = [];
        
        zerolen = [];

    end
    
    methods
        function obj = TekPULSEGROUP(name)
            obj = obj@AWGPULSEGROUP(name);
        end
    end
end