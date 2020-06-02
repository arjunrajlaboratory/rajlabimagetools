classdef CompositeImageMaker < handle
    
    properties (Access = private)
        alexaImageHolder
        cyImageHolder
        tmrImageHolder
        nirImageHolder
        gfpImageHolder
        dapi2dIntensityImageHolder
        trans2dIntensityImageHolder
        parametersHolder
    end
    
    methods
        function p = CompositeImageMaker(alexaImageHolder, cyImageHolder, tmrImageHolder, nirImageHolder, gfpImageHolder, ...
                dapi2dIntensityImageHolder, ...
                trans2dIntensityImageHolder, parametersHolder)
            
            p.alexaImageHolder = alexaImageHolder;
            p.cyImageHolder = cyImageHolder;
            p.tmrImageHolder = tmrImageHolder;
            p.nirImageHolder = nirImageHolder;
            p.gfpImageHolder = gfpImageHolder;
            p.dapi2dIntensityImageHolder = dapi2dIntensityImageHolder;
            p.trans2dIntensityImageHolder = trans2dIntensityImageHolder;
            p.parametersHolder = parametersHolder;
        end
        
        
        function img = getImage(p)
            
            
            intensityImg = zeros(size(p.dapi2dIntensityImageHolder.getImage()));
            img = cat(3, intensityImg, intensityImg, intensityImg);
            
            if p.parametersHolder.getValue('showCy')
                cyImg = p.cyImageHolder.getImage();
                cyColor = p.parametersHolder.getValue('colorCy');
                cyScale = p.parametersHolder.getValue('scaleCy');
                img = addLayerToRGBImage(img, cyImg, cyColor, cyScale);
            end
            
            if p.parametersHolder.getValue('showAlexa')
                alexaImg = scale(p.alexaImageHolder.getImage());
                alexaColor = p.parametersHolder.getValue('colorAlexa');
                alexaScale = p.parametersHolder.getValue('scaleAlexa');
                img = addLayerToRGBImage(img, alexaImg, alexaColor, alexaScale);
            end
            
            if p.parametersHolder.getValue('showTmr')
                tmrImg = p.tmrImageHolder.getImage();
                tmrColor = p.parametersHolder.getValue('colorTmr');
                tmrScale = p.parametersHolder.getValue('scaleTmr');
                img = addLayerToRGBImage(img, tmrImg, tmrColor, tmrScale);
            end

            if p.parametersHolder.getValue('showGfp')
                gfpImg = p.tmrImageHolder.getImage();
                gfpColor = p.parametersHolder.getValue('colorGfp');
                gfpScale = p.parametersHolder.getValue('scaleGfp');
                img = addLayerToRGBImage(img, gfpImg, gfpColor, gfpScale);
            end
            
            if p.parametersHolder.getValue('showNir')
                nirImg = p.tmrImageHolder.getImage();
                nirColor = p.parametersHolder.getValue('colorNir');
                nirScale = p.parametersHolder.getValue('scaleNir');
                img = addLayerToRGBImage(img, nirImg, nirColor, nirScale);
            end            
            
            if p.parametersHolder.getValue('showDapi')
                dapiImg = p.dapi2dIntensityImageHolder.getImage() / 2;
                dapiColor = p.parametersHolder.getValue('colorDapi');
                dapiScale = p.parametersHolder.getValue('scaleDapi');
                img = addLayerToRGBImage(img, dapiImg, dapiColor, dapiScale);
            end
            
            if p.parametersHolder.getValue('showTrans')
                transImg = p.trans2dIntensityImageHolder.getImage() / 2;
                transColor = p.parametersHolder.getValue('colorTrans');
                transScale = p.parametersHolder.getValue('scaleTrans');
                throwErrorIfNotAColor(transColor)
                img = addLayerToRGBImage(img, transImg, transColor, transScale);
            end
        end
    end
end
 
function throwErrorIfNotAColor(color)
    assert(length(color) == 3 && isnumeric(color), 'improc2:BadArguments', 'Must be RGB color code in the format 0 0 0');
end

function img = addLayerToRGBImage(img, imToAdd, colorAsRGB, scaleFactor)
    
    imToAddRGB = cat(3, imToAdd * colorAsRGB(1), ...
        imToAdd * colorAsRGB(2), ...
        imToAdd * colorAsRGB(3));
    img = img + scaleFactor*imToAddRGB;
    img = min(img, 1);
end
