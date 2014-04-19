classdef MockCentroidSelectionResponder < handle
    %UNTITLED16 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        spotsAndCentroids;
    end
    
    methods
        function p = MockCentroidSelectionResponder(spotsAndCentroids)
            p.spotsAndCentroids = spotsAndCentroids;
        end
        
        function selectCentroid(p, centroidIndex)
            display(['Selected centroid ', num2str(centroidIndex), ' with:'])
            for channelName = p.spotsAndCentroids.channelNames;
                numSpots = p.spotsAndCentroids.getNumSpotsForCentroids(channelName);
                display([channelName{1}, ' numSpots: ', num2str(numSpots(centroidIndex))])
            end
        end
    end
    
end

