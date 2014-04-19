classdef MaxSettingContraster < improc2.interfaces.ScaledImageContraster
    
    properties (Access = private)
        getMaxIntensityFUNC
    end
    
    methods
        function p = MaxSettingContraster(getMaxIntensityFUNC)
            p.getMaxIntensityFUNC = getMaxIntensityFUNC;
        end
        
        function contrastedImg = contrast(p, scaledImg, minAndMaxOfUnscaledImg)
            desiredMaxIntensity = p.getMaxIntensityFUNC();
            minIntensity = minAndMaxOfUnscaledImg(1);
            maxIntensity = minAndMaxOfUnscaledImg(2);
            contrastedImg = scaledImg ...
                * (maxIntensity - minIntensity) ...
                / (desiredMaxIntensity - minIntensity);
            contrastedImg = min(contrastedImg, 1);
        end 
    end
end

