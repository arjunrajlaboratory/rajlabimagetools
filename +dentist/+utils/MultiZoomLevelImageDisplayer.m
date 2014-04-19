classdef MultiZoomLevelImageDisplayer < dentist.utils.AbstractDisplayer
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        zoomTransitionsInPixels
        zoomLevel
        currentDisplayer
        cellArrayOfDisplayers
        viewportHolder
    end
    
    
    methods
        function p = MultiZoomLevelImageDisplayer(viewportHolder, ...
                zoomTransitionsInPixels, varargin)
            assert(isnumeric(zoomTransitionsInPixels), ...
                'zoomTransitions should be numeric')
            assert(all(diff(zoomTransitionsInPixels) > 0), ...
                'zoomTransitions must be monotonically increasing')
            assert(length(zoomTransitionsInPixels) == length(varargin) -1, ...
                'length(zoomTransitions) must be number of Displayers minus 1')
            p.viewportHolder = viewportHolder;
            p.zoomTransitionsInPixels = zoomTransitionsInPixels;
            p.cellArrayOfDisplayers = varargin;
        end
        
        function draw(p)
            viewport = p.viewportHolder.getViewport();
            requestedZoomLevel = p.calculateZoomLevel(viewport);
            if isempty(p.zoomLevel)
                p.currentDisplayer = p.cellArrayOfDisplayers{requestedZoomLevel};
            elseif p.zoomLevel ~= requestedZoomLevel
                p.currentDisplayer.deactivate();
                p.currentDisplayer = p.cellArrayOfDisplayers{requestedZoomLevel};
            end
            p.currentDisplayer.draw();
            p.zoomLevel = requestedZoomLevel;
        end
        
        function deactivate(p)
            p.currentDisplayer.deactivate();
        end
    end
    
    
    methods (Access = private)
        function zoomLevel = calculateZoomLevel(p, viewport)
            levelTooSmallForWidth = viewport.width > p.zoomTransitionsInPixels;
            levelTooSmallForHeight = viewport.height > p.zoomTransitionsInPixels;
            numLevelsTooSmall = sum(levelTooSmallForWidth | levelTooSmallForHeight);
            zoomLevel = numLevelsTooSmall + 1;
        end
    end
    
end

