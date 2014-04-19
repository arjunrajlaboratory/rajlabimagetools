classdef ContrastedScaledImageHolder < handle
    
    properties (Access = private)
        scaledImageHolder
        contraster
    end
    
    methods
        function p = ContrastedScaledImageHolder(scaledImageHolder, contraster)
            p.scaledImageHolder = scaledImageHolder;
            p.contraster = contraster;
        end
        
        function img = getImage(p)
            [scaledImg, minAndMaxInUnscaledImg] = p.scaledImageHolder.getImage();
            img = p.contraster.contrast(scaledImg, minAndMaxInUnscaledImg);
        end
    end
end

