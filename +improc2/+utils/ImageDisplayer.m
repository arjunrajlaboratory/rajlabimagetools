classdef ImageDisplayer < dentist.utils.AbstractDisplayer
    
    properties (GetAccess = private, SetAccess = private)
        imageHolder
        axH
        viewportHolder
        imageH
    end
    
    methods
        function p = ImageDisplayer(axH, imageHolder, viewportHolder)
            p.axH = axH;
            p.imageHolder = imageHolder;
            p.viewportHolder = viewportHolder;
        end
        function draw(p)
            
            viewport = p.viewportHolder.getViewport();
            [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport);
            p.setAxesToFitCroppedImage(viewport);
            
            img = p.imageHolder.getImage();
            img = viewport.getCroppedImage(img);
            
            p.clearGraphics();
            
            p.imageH = image('CData', img, 'XData', xCoords, 'YData', yCoords,...
                'CDataMapping', 'scaled', 'Parent', p.axH, 'HitTest', 'off');
        end
        function deactivate(p)
            p.clearGraphics();
        end
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ishandle(p.imageH)
                delete(p.imageH)
            end
        end
        function setAxesToFitCroppedImage(p, viewport)
            [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport);
            set(p.axH, 'XLim', xCoords + [-0.5, 0.5], ...
                'YLim', yCoords + [-0.5, 0.5])
        end
    end
end

function [xCoords, yCoords] = getXDataAndYDataFromViewport(viewport)
    xCoords = viewport.ulCornerXPosition + [0, viewport.width - 1];
    yCoords = viewport.ulCornerYPosition + [0, viewport.height - 1];
end
