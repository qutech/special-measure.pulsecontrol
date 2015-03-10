classdef TestSetup

    properties(SetAccess = protected, GetAccess = protected)
        duration;
        inputChannel;
    end
    
    methods(Abstract, Access = public)
        initiate(self);
        run(self);
    end
    
    methods(Abstract, Access = protected)
        
        initVAWG(self);
        
        initDAC(self);
        
        initPulseGroup(self);
        
        evaluate(self, measured);
        
    end
    
end

