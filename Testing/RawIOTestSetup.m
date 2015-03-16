classdef RawIOTestSetup < DefaultTestSetup
    
    methods(Access = public)
        
        function obj = RawIOTestSetup()
            obj = obj@DefaultTestSetup(1000000, 1, 1e-3, .5e-2);
        end
        
    end
    
end

