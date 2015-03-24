classdef PXDAC_DC < PXDAC
    properties (Constant,GetAccess = public)
        allowedVoltageRange = [0.400 1.450];
    end
    
    methods
        function obj = PXDAC_DC(id,index)
            obj = obj@PXDAC(id,index);
            
            %check version
            if ~calllib('PXDAC4800_64','IsDcXD48',obj.handle)
                error('Detected a AC coupled card in PXDAC_DC constructor.');
            end
        end
    end
end