classdef ScaledImageContraster < handle

    properties
    end
    
    methods (Abstract = true)
        contrastedImg = contrast(scaledImg, minAndMaxInUnscaledImg)
    end
    
end

