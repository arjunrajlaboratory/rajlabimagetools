classdef CompositeImageMaker < handle
    
    properties (Access = private)
        rna2dIntensityImageHolder
        dapi2dIntensityImageHolder
        trans2dIntensityImageHolder
        parametersHolder
    end
    
    methods
        function p = CompositeImageMaker(rna2dIntensityImageHolder, ...
                dapi2dIntensityImageHolder, ...
                trans2dIntensityImageHolder, parametersHolder)
            
            p.rna2dIntensityImageHolder = rna2dIntensityImageHolder;
            p.dapi2dIntensityImageHolder = dapi2dIntensityImageHolder;
            p.trans2dIntensityImageHolder = trans2dIntensityImageHolder;
            p.parametersHolder = parametersHolder;
        end
        
        function img = getImage(p)
            intensityImg = p.rna2dIntensityImageHolder.getImage();
            img = cat(3, intensityImg, intensityImg, intensityImg);
            
            if p.parametersHolder.getValue('showDapi')
                dapiImg = p.dapi2dIntensityImageHolder.getImage() / 2;
                dapiColor = [1, 0, 1];
                img = addLayerToRGBImage(img, dapiImg, dapiColor);
            end
            
            if p.parametersHolder.getValue('showTrans')
                transImg = p.trans2dIntensityImageHolder.getImage() / 2;
                transColor = [1, 1, 0];
                img = addLayerToRGBImage(img, transImg, transColor);
            end
        end
    end
end

function img = addLayerToRGBImage(img, imToAdd, colorAsRGB)
    imToAddRGB = cat(3, imToAdd * colorAsRGB(1), ...
        imToAdd * colorAsRGB(2), ...
        imToAdd * colorAsRGB(3));
    img = img + imToAddRGB;
    img = min(img, 1);
end
