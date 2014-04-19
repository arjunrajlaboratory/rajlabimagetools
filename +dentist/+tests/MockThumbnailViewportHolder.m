classdef MockThumbnailViewportHolder < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        viewport
        axH
    end
    
    methods
        function p = MockThumbnailViewportHolder(axH)
            p.axH = axH;
        end
        function viewport = getThumbnailViewport(p)
            viewport = p.viewport;
        end
        function setThumbnailViewport(p, viewport)
            p.viewport = viewport;
            p.viewport.drawBoundaryRectangle('Parent', p.axH, ...
                'EdgeColor', 'w', 'HitTest', 'off');
        end
    end
    
end

