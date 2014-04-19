classdef ImageObjectScaledImageSliceHolder
    
    properties (Access = private)
        objectHandle
        channelHolder
        croppedImageProvider
        imageSlicer
    end
    
    methods
        function p = ImageObjectScaledImageSliceHolder(...
                objectHandle, channelHolder, croppedImageProvider, imageSlicer)
            p.objectHandle = objectHandle;
            p.channelHolder = channelHolder;
            p.croppedImageProvider = croppedImageProvider;
            p.imageSlicer = imageSlicer;
        end
        
        function [scaledImg, minAndMaxInUnscaledImage] = getImage(p)
            croppedImg = p.croppedImageProvider.getImage(...
                p.objectHandle, p.channelHolder.getChannelName);
            minVal = min(croppedImg(:));
            maxVal = max(croppedImg(:));
            minAndMaxInUnscaledImage = [minVal, maxVal];
            img = p.imageSlicer.sliceImage(croppedImg);
            scaledImg = improc2.utils.scale(img, minAndMaxInUnscaledImage);
        end
    end
    
end

