classdef MockSpotsAndCentroidsSource < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        centroids
        spots
        assignedCentroidsToSpots
        numspotsArray
    end
    
    methods
        function p = MockSpotsAndCentroidsSource(centroids, spots, ...
                assignedCentroidsToSpots)
            p.centroids = centroids;
            p.spots = spots;
            p.assignedCentroidsToSpots = assignedCentroidsToSpots;
            p.calculateNumSpots();
        end
        
        function centroids = getCentroids(p)
            centroids = p.centroids;
        end
        
        function spots = getSpots(p, channelName)
            spots = p.spots.getByChannelName(channelName);
        end
        
        function spotToCentroidMapping = getSpotToCentroidMapping(p, channelName)
            spotToCentroidMapping = p.assignedCentroidsToSpots.getByChannelName(channelName);
        end
        
        function numspots = getNumSpotsForCentroids(p,channelName)
            numspots = p.numspotsArray.getByChannelName(channelName);
        end
    end
    
    methods (Access = private)
        function calculateNumSpots(p)
            p.numspotsArray = dentist.utils.ChannelArray(...
                p.assignedCentroidsToSpots.channelNames);
            for channelName = p.numspotsArray.channelNames
                assignedCentroids = p.assignedCentroidsToSpots.getByChannelName(channelName);
                numSpots = zeros(length(p.centroids), 1);
                for centroidNum = 1:length(numSpots)
                    numSpots(centroidNum) = sum(assignedCentroids == centroidNum);
                end
                p.numspotsArray = p.numspotsArray.setByChannelName(numSpots, channelName);
            end
        end
    end
    
end

