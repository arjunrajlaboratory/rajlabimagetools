classdef TiledImageDisplayer < dentist.utils.AbstractDisplayer
    
    properties (GetAccess = private, SetAccess = private)
        imageProvider
        channelHolder
        axH
        imageH
        viewportHolder
    end
    
    methods
        function p = TiledImageDisplayer(axH, imageProvider, channelHolder,...
                viewportHolder)
            p.axH = axH;
            p.imageProvider = imageProvider;
            p.channelHolder = channelHolder;
            p.viewportHolder = viewportHolder;
        end
        
        function draw(p)
            
            viewport = p.viewportHolder.getViewport();
            channelName = p.channelHolder.getChannelName();
            
            [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport);
            p.setAxesToFitCroppedImage(viewport);
            img = viewport.getCroppedImage(p.imageProvider, channelName);
            imgDapi = viewport.getCroppedImage(p.imageProvider,'dapi'); %syd edits!
            rgbImg = p.makeIntoRGB(scale(img),scale(imgDapi));
            
            p.deactivate();
            p.imageH = image('CData', rgbImg, 'XData', xCoords, 'YData', yCoords, ...
                'CDataMapping', 'scaled', 'Parent', p.axH, 'HitTest', 'off');
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
        
        function attachShowDapiUIControl(p, uihandle)
        end
        function attachBoostContrastUIControl(p, uihandle)
        end
        
    end
    
    methods (Access = private)
        function setAxesToFitCroppedImage(p, viewport)
            [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport);
            set(p.axH, 'XLim', xCoords + [-0.5, 0.5], ...
                'YLim', yCoords + [-0.5, 0.5])
        end
        function clearGraphics(p)
            if ishandle(p.imageH)
                delete(p.imageH)
            end
        end
        function rgbImage = makeIntoRGB(p, img, imgDapi)
            rgbImage = cat(3, img/2, img/2, (img + imgDapi)/2); %syd edits
        end
    end
end

function [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport)
    xCoords = viewport.ulCornerXPosition + [0, viewport.width - 1];
    yCoords = viewport.ulCornerYPosition + [0, viewport.height - 1];
end
