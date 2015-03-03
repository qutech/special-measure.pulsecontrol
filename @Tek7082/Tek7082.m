classdef Tek7082 < TekAWG
    properties (Constant,GetAccess = public)
        nChannels = 2;
        possibleResolutions = 14;
    end
    
     methods
         %constructor
         function obj = Tek7082(id,handle)
             obj = obj@TekAWG(id,handle);
         end
     end
end