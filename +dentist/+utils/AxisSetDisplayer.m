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
                [-0.5, (viewport.width*0.1 - 1 + 0.5)], 'YLim', ...
                viewport.ulCornerYPosition + [-0.5, (viewport.height*0.1 -1 +0.5)])
            % multiplying by 0.1 helps everything load faster
            % we apply the 0.1 multiplier to the centroid positions as well
            % in 'CentroidsDisplayer.m'
        end
        function deactivate(p)
        end
    end
    
end
