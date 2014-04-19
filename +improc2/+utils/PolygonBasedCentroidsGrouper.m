classdef PolygonBasedCentroidsGrouper < handle
    
    properties (Access = private)
        centroidsGrouper
        centroidsSource
        actionsAfterGrouping
    end
    
    methods
        function p = PolygonBasedCentroidsGrouper(centroidsGrouper, centroidsSource)
            p.centroidsGrouper = centroidsGrouper;
            p.centroidsSource = centroidsSource;
            p.actionsAfterGrouping = improc2.utils.DependencyRunner();
        end
        
        function groupAllInPolygon(p, polygon)
            centroids = p.centroidsSource.getCentroids();
            centroidIsInPolygon = inpolygon(...
                centroids.xPositions, centroids.yPositions, ...
                polygon(:,1), polygon(:,2));
            centroidsToGroup = find(centroidIsInPolygon);
            p.centroidsGrouper.assignItemsToAGroup(centroidsToGroup);
            
            p.actionsAfterGrouping.runDependencies();
        end
        
        function addActionAfterGrouping(p, handleToObject, funcToRunOnIt)
            p.actionsAfterGrouping.registerDependency(handleToObject, funcToRunOnIt);
        end
    end
end

