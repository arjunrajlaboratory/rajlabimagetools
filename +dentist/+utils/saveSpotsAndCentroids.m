function [assignedSpots, centroids, spotToCentroidMappings] = saveSpotsAndCentroids(...
        spotsAndCentroids)
    
    centroids = spotsAndCentroids.getCentroids();
    
    channelNames = spotsAndCentroids.channelNames;
    
    assignedSpots = dentist.utils.makeFilledChannelArray(channelNames, ...
        @(channelName) spotsAndCentroids.getSpots(channelName));
    
    spotToCentroidMappings = dentist.utils.makeFilledChannelArray(...
        channelNames, ...
        @(channelName) spotsAndCentroids.getSpotToCentroidMapping(channelName));
    
    