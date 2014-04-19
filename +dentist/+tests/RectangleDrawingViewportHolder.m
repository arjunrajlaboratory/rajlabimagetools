classdef RectangleDrawingViewportHolder < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        viewport
        axH
    end
    
    methods
        function p = RectangleDrawingViewportHolder(axH)
            if nargin == 1
                p.axH = axH;
            end
        end
        function viewport = getViewport(p)
            viewport = p.viewport;
        end
        function setViewport(p, viewport)
            p.viewport = viewport;
            if ~isempty(p.axH)
                p.viewport.drawBoundaryRectangle('Parent', p.axH, ...
                    'EdgeColor', 'w', 'HitTest', 'off');
            end
        end
    end
    
end

