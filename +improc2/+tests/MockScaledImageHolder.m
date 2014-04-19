classdef MockScaledImageHolder < handle
    
    properties (Access = private)
        scaledIm
        minAndMax
    end
    
    methods
        function p = MockScaledImageHolder(scaledIm, minAndMax)
            p.scaledIm = scaledIm;
            p.minAndMax = minAndMax;
        end
        
        function [scaledIm, minAndMax] = getImage(p)
            scaledIm = p.scaledIm;
            minAndMax = p.minAndMax;
        end
    end
    
end

