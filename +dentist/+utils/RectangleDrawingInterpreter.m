classdef RectangleDrawingInterpreter < dentist.utils.MouseGestureInterpreter
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected, GetAccess = protected)
        rectangleHandle;
        x0
        y0
        width
        height
    end
    
    methods
        function p = RectangleDrawingInterpreter()
        end
        
        function moveCallback(p, varargin)
            p.drawRectangleAndSaveCoords;
        end
        
        function doAfterButtonUp(p, varargin)
            p.getSelectedRectangleCoords();
            if ishandle(p.rectangleHandle)
                delete(p.rectangleHandle);
            end
        end
        
        function drawRectangleAndSaveCoords(p)
            if ishandle(p.rectangleHandle)
                delete(p.rectangleHandle)
            end
            p.getSelectedRectangleCoords();
            % rectangle built-in will fail if any dimension is 0.
            if p.width > 0 && p.height > 0
                p.rectangleHandle = rectangle(...
                    'Position', [p.x0, p.y0, p.width, p.height], ...
                    'EdgeColor', 'r', ...
                    'Parent', p.axH);
            end
        end
        
        function getSelectedRectangleCoords(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            xLimits = xlim(p.axH);
            yLimits = ylim(p.axH);
            
            currentPoint(1,1) = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
            currentPoint(1,2) = max(min(currentPoint(1,2), yLimits(2)), yLimits(1));
            
            p.x0 = min(p.pointAtButtonDown(1,1), currentPoint(1,1));
            p.y0 = min(p.pointAtButtonDown(1,2), currentPoint(1,2));
            p.width = abs(p.pointAtButtonDown(1,1) - currentPoint(1,1));
            p.height = abs(p.pointAtButtonDown(1,2) - currentPoint(1,2));

        end
        
    end
    
end

