classdef SpotsAndCentroids < handle
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        spotsChannelArray
        centroids
        spotsToCentroidsMappings
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = SpotsAndCentroids(spotsChannelArray, centroids, ...
                spotsToCentroidsMappings)
            p.spotsChannelArray = spotsChannelArray;
            p.centroids = centroids;
            p.spotsToCentroidsMappings = spotsToCentroidsMappings;
        end
        
        function spots = getSpots(p, channelName)
            spots = p.spotsChannelArray.getByChannelName(channelName);
        end
        
        function centroids = getCentroids(p)
            centroids = p.centroids;
        end
        
        function spotToCentroidMapping = getSpotToCentroidMapping(p, channelName)
            spotToCentroidMapping = ...
                p.spotsToCentroidsMappings.getByChannelName(channelName);
        end
        
        function [numSpotsForCentroids, spotToCentroidMapping] = ...
                            getNumSpotsForCentroids(p, channelName)
            spotToCentroidMapping = p.getSpotToCentroidMapping(channelName);
            numSpotsForCentroids = dentist.utils.occurrencesOfIntegersUpToN(...
                spotToCentroidMapping, length(p.getCentroids()));
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.spotsChannelArray.channelNames;
        end
    end
    
end

