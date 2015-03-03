classdef Tek7082 < TekAWG
    properties (Constant,GetAccess = public)
        nChannels = 2;
        possibleResolutions = 14;
    end
    
     methods
         %constructor
         function obj = Tek7082(id,handle)
             obj = obj@TekAWG(id,handle);
             obj.resolution = obj.possibleResolutions(1); %in bits
         end
     end
end