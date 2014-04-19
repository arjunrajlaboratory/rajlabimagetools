classdef MockCentroidsAndNumSpotsSource < handle
    %UNTITLED14 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        centroids
        numspotsArray
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = MockCentroidsAndNumSpotsSource(centroids, numspotsArray)
            p.centroids = centroids;
            p.numspotsArray = numspotsArray;
        end
        
        function centroids = getCentroids(p)
            centroids = p.centroids;
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.numspotsArray.channelNames;
        end
        
        function numspots = getNumSpotsForCentroids(p, channelName)
            numspots = p.numspotsArray.getByChannelName(channelName);
        end
        
    end
    
end

