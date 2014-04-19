classdef ThumbnailPanningMouseInterpreter < dentist.utils.LineDrawingInterpreter
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        thumbnailViewportHolder;
    end
    
    methods
        function p = ThumbnailPanningMouseInterpreter(thumbnailViewportHolder)
            p.thumbnailViewportHolder = thumbnailViewportHolder;
        end
        
        function wireToFigureAndAxes(p, varargin)
            p.wireToFigureAndAxes@dentist.utils.LineDrawingInterpreter(varargin{:});
        end
        
        function doAfterButtonUp(p)
            p.doAfterButtonUp@dentist.utils.LineDrawingInterpreter();
            currentPoint = get(p.axH, 'CurrentPoint');
            xLimits = xlim(p.axH);
            yLimits = ylim(p.axH);
            currentPoint(1,1) = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
            currentPoint(1,2) = max(min(currentPoint(1,2), yLimits(2)), yLimits(1));
            mouseDisplacement = currentPoint(1,1:2) - p.pointAtButtonDown(1,1:2);
            requestedViewportDisplacement = mouseDisplacement;
            
            viewport = p.thumbnailViewportHolder.getThumbnailViewport();
            requestedCenterX = viewport.centerXPosition + requestedViewportDisplacement(1);
            requestedCenterY = viewport.centerYPosition + requestedViewportDisplacement(2);
            viewport = viewport.centerAndScaleSize(requestedCenterX, requestedCenterY);
            p.thumbnailViewportHolder.setThumbnailViewport(viewport); 
        end
    end
    
end

