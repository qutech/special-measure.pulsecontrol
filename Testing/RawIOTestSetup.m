classdef RawIOTestSetup < DefaultTestSetup
    
    properties(SetAccess = protected, GetAccess = public)
        errorThreshold = 1e-3; % RMS error threshold in Volt
    end
end

