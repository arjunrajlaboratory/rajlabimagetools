classdef ImageSizeAdaptiveViewportHolder < handle
    
    properties (Access = private)
        storedViewport
        imageHolder
    end
    
    methods
        function p = ImageSizeAdaptiveViewportHolder(imageHolder)
            p.imageHolder = imageHolder;
            p.storedViewport = p.makeNewViewportFromCurrentImage();
        end
        
        function viewport = getViewport(p)
            viewport = p.makeNewViewportFromCurrentImage();
            if p.storedViewportIsFullyZoomedOut()
                return;
            else
                viewport = viewport.setWidth(p.storedViewport.width);
                viewport = viewport.setHeight(p.storedViewport.height);
                adaptedCenterXPosition = p.storedViewport.centerXPosition * ...
                    viewport.imageWidth / p.storedViewport.imageWidth;
                adaptedCenterYPosition = p.storedViewport.centerYPosition * ...
                    viewport.imageHeight / p.storedViewport.imageHeight;
                viewport = viewport.tryToCenterAtXPosition(...
                    adaptedCenterXPosition);
                viewport = viewport.tryToCenterAtYPosition(...
                    adaptedCenterYPosition);
            end 
        end
        
        function setViewport(p, viewport)
            p.storedViewport = viewport;
        end
    end
    
    methods (Access = private)
        function viewport = makeNewViewportFromCurrentImage(p)
            imageSize = size(p.imageHolder.getImage());
            imgWidth = imageSize(2);
            imgHeight = imageSize(1);
            viewport = dentist.utils.ImageViewport(imgWidth, imgHeight);
        end
        
        function boolean = storedViewportIsFullyZoomedOut(p)
            boolean = (p.storedViewport.width == p.storedViewport.imageWidth) ...
                && (p.storedViewport.height == p.storedViewport.imageHeight);
        end
    end
    
end

