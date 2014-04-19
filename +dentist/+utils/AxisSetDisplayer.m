classdef AxisSetDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        axH
        viewportHolder
    end
    
    methods
        function p = AxisSetDisplayer(axH, viewportHolder)
            p.axH = axH;
            p.viewportHolder = viewportHolder;
        end
        function draw(p)
            viewport = p.viewportHolder.getViewport();
            set(p.axH, 'XLim', viewport.ulCornerXPosition + ...
                [-0.5, (viewport.width - 1 + 0.5)], 'YLim', ...
                viewport.ulCornerYPosition + [-0.5, (viewport.height -1 +0.5)])
        end
        function deactivate(p)
        end
    end
    
end
