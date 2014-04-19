classdef FreeHandDrawingInterpreter < dentist.utils.MouseGestureInterpreter
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        polygonLineHandle;
    end
    properties (SetAccess = private, GetAccess = protected)
        polygonXs;
        polygonYs;
    end
    
    methods
        function p = FreeHandDrawingInterpreter()
        end
        
        function doOnButtonDown(p)
            p.polygonXs = p.pointAtButtonDown(1,1);
            p.polygonYs = p.pointAtButtonDown(1,2);
        end
        
        function moveCallback(p, varargin)
            p.addPolygonEdge;
            p.drawPolygon;
        end
        
        function doAfterButtonUp(p, varargin)
            delete(p.polygonLineHandle)
        end
        
        function addPolygonEdge(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            p.polygonXs = [p.polygonXs, currentPoint(1,1)];
            p.polygonYs = [p.polygonYs, currentPoint(1,2)];
        end
        
        function drawPolygon(p)
            if ishandle(p.polygonLineHandle)
                set(p.polygonLineHandle, 'XData', p.polygonXs, ...
                    'YData', p.polygonYs);
            else
                p.polygonLineHandle = line(p.polygonXs, p.polygonYs);
            end
        end
            
    end
    
end

