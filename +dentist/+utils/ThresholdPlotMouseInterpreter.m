classdef ThresholdPlotMouseInterpreter < dentist.utils.MouseGestureInterpreter
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        thresholdPlotPlugin
        lineHandle
        currentXPosition
    end
    
    methods
        function p = ThresholdPlotMouseInterpreter(thresholdPlotPlugin)
            p.thresholdPlotPlugin = thresholdPlotPlugin;
        end
        
        function moveCallback(p, varargin)
            p.drawLine;
        end
        
        function doAfterButtonUp(p, varargin)
            if ~isempty(p.lineHandle) && ishandle(p.lineHandle)
                delete(p.lineHandle);
            end
            p.getCurrentXPosition
            width = abs(p.pointAtButtonDown(1,1) - p.currentXPosition);
            if width < 1e-3
                p.doOnPointSelection()
            else
                p.zoomToRange()
            end
        end
    end
    
    methods (Access = private)
        function zoomToRange(p)
            desiredLimits = sort([p.currentXPosition, p.pointAtButtonDown(1,1)], 'ascend');
            set(p.axH, 'XLim', desiredLimits)
        end
        
        function doOnPointSelection(p)
            switch p.selectionTypeAtButtonDown
                case 'normal' %left-click
                    p.thresholdPlotPlugin.setThreshold(p.currentXPosition);
                case 'alt'  %right-click
                    set(p.axH, 'XLim', [0 Inf])
            end
        end
        
        function getCurrentXPosition(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            xLimits = xlim(p.axH);
            p.currentXPosition = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
        end
        
        function drawLine(p)
            if ishandle(p.lineHandle)
                delete(p.lineHandle)
            end
            p.getCurrentXPosition();
            p.lineHandle = line(...
                [p.pointAtButtonDown(1,1), p.currentXPosition], ...
                [p.pointAtButtonDown(1,2), p.pointAtButtonDown(1,2)], ...
                'Parent', p.axH, 'Color', 'k');
        end
        
    end
end

