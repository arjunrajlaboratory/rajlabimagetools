classdef notifyingClickedSpotsCollection < ...
        improc2.txnSites3.interfaces.manualSpotCollection
%Object to tell the transcriptionSiteCollector of Changes    
    properties (Access = private)
        clickedSpotsCollection
        actionsOnChangeOfNumClickedPoints
    end
    
    methods
        function p = notifyingClickedSpotsCollection(...
                clickedSpotsCollection)
            p.clickedSpotsCollection = clickedSpotsCollection;
            p.actionsOnChangeOfNumClickedPoints = ...
                improc2.utils.DependencyRunner();
        end
        
        function addClickedSpot(p, x, y)
            p.clickedSpotsCollection.addClickedSpot(x,y);
            p.actionsOnChangeOfNumClickedPoints.runDependencies();
        end
        
        function [Xs, Ys] = getClickedSpotCoordinates(p)
            [Xs, Ys] =  p.clickedSpotsCollection.getClickedSpotCoordinates();
        end
        
        function [Xs, Ys, Zs, parentNodeName] = getNearbySpotCoordinates(p)
            [Xs, Ys, Zs, parentNodeName] =  p.clickedSpotsCollection.getNearbySpotCoordinates();
        end
        
        function Ints = getNearbyIntensities(p)
            Ints = p.clickedSpotsCollection.getNearbyIntensities();
        end
        
        function addActionAfterChangeOfNumClickedPoints(p, handleToObject, funcToRunOnIt)
            p.actionsOnChangeOfNumClickedPoints.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function deleteClickedSpot(p, pointID)
            p.clickedSpotsCollection.deleteClickedSpot(pointID);
            p.actionsOnChangeOfNumClickedPoints.runDependencies();
        end
        
        function moveClickedSpot(p, pointID, newX, newY)
            p.clickedSpotsCollection.moveClickedSpot(pointID, newX, newY);
            p.actionsOnChangeOfNumClickedPoints.runDependencies();
        end
    end
end

