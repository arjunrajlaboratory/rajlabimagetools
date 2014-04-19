classdef FocuserOfViewportOnSelectedCentroid < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        spotsAndCentroids;
        viewportHolder;
        viewportSizeOnFocusing;
    end
    
    methods
        function p = FocuserOfViewportOnSelectedCentroid(spotsAndCentroids, ...
                viewportHolder, viewportSizeOnFocusing)
            p.spotsAndCentroids = spotsAndCentroids;
            p.viewportHolder = viewportHolder;
            p.viewportSizeOnFocusing = viewportSizeOnFocusing;
        end
        
        function selectCentroid(p, centroidIndex)
            centroids = p.spotsAndCentroids.getCentroids();
            viewport = p.viewportHolder.getViewport();
            viewport = viewport.setWidth(p.viewportSizeOnFocusing);
            viewport = viewport.setHeight(p.viewportSizeOnFocusing);
            viewport = viewport.tryToCenterAtXPosition(...
                centroids.xPositions(centroidIndex));
            viewport = viewport.tryToCenterAtYPosition(...
                centroids.yPositions(centroidIndex));
            p.viewportHolder.setViewport(viewport);
        end
    end
    
end

