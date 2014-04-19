classdef ImageZoomingMouseInterpreter < dentist.utils.RectangleDrawingInterpreter
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        viewportHolder
    end
    
    methods
        function p = ImageZoomingMouseInterpreter(viewportHolder)
            p.viewportHolder = viewportHolder;
        end
        
        function wireToFigureAndAxes(p, varargin)
            p.wireToFigureAndAxes@dentist.utils.RectangleDrawingInterpreter(varargin{:});
        end
        
        function doAfterButtonUp(p, varargin)
            p.doAfterButtonUp@dentist.utils.RectangleDrawingInterpreter(varargin{:});
            if p.width == 0 && p.height == 0
                p.zoomAtPoint();
            elseif p.width > 0 && p.height > 0
                p.zoomToRectangle();
            end
        end
    end
    
    methods (Access = private)
        function zoomToRectangle(p)
            viewport = p.viewportHolder.getViewport();
            viewport = viewport.setFromRectanglePosition(...
                p.x0, p.y0, p.width, p.height);
            p.viewportHolder.setViewport(viewport);
        end
        
        function zoomAtPoint(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            switch p.selectionTypeAtButtonDown
                case 'normal' %left-click --> zoom-in
                    scaleFactor = 0.80;
                case 'alt'  %right-click --> zoom-out
                    scaleFactor = 1.25;
                case 'open' %double-click --> zoom to full img.
                    scaleFactor = Inf;
            end
            viewport = p.viewportHolder.getViewport();
            viewport = viewport.centerAndScaleSize(...
                currentPoint(1,1), currentPoint(1,2), scaleFactor);
            p.viewportHolder.setViewport(viewport);
        end
    end
    
end

