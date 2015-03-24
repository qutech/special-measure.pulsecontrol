classdef PXDAC_AC < PXDAC
    properties (Constant,GetAccess = public)
        allowedVoltageRange = [0.47 1.450];
    end
    
    methods
        function obj = PXDAC_AC(id,index)
            obj = obj@PXDAC(id,index);
            
            %check version
            if calllib('PXDAC4800_64','IsDcXD48',obj.handle)
                error('Detected a DC coupled card in PXDAC_AC constructor.');
            end
        end
    end
end