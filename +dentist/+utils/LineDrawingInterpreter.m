classdef LineDrawingInterpreter < dentist.utils.MouseGestureInterpreter
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        lineHandle;
    end
    
    methods
        function p = LineDrawingInterpreter()
        end
        
        function moveCallback(p, varargin)
            p.drawLine;
        end
        
        function doAfterButtonUp(p, varargin)
            p.clearLine();
        end
    end
    
    methods (Access = private)
        function drawLine(p)
            p.clearLine();
            currentPoint = get(p.axH, 'CurrentPoint');
            xLimits = xlim(p.axH);
            yLimits = ylim(p.axH);
            currentPoint(1,1) = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
            currentPoint(1,2) = max(min(currentPoint(1,2), yLimits(2)), yLimits(1));
            p.lineHandle = line(...
                [p.pointAtButtonDown(1,1), currentPoint(1,1)], ...
                [p.pointAtButtonDown(1,2), currentPoint(1,2)]);
        end
        
        function clearLine(p)
            if ~isempty(p.lineHandle) && ishandle(p.lineHandle)
                delete(p.lineHandle)
            end
        end
    end
    
end

