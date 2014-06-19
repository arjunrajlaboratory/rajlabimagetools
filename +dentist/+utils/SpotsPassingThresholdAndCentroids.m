classdef SpotsPassingThresholdAndCentroids < handle
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        candidateSpotsAndCentroids
        thresholdsHolder
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = SpotsPassingThresholdAndCentroids(candidateSpotsAndCentroids, thresholdsHolder)
            p.candidateSpotsAndCentroids = candidateSpotsAndCentroids;
            p.thresholdsHolder = thresholdsHolder;
        end
        
        function spots = getSpots(p, channelName)
            candidates = p.candidateSpotsAndCentroids.getSpots(channelName);
            threshold = p.thresholdsHolder.getThreshold(channelName);
            spots = candidates.subsetByIndices(candidates.intensities > threshold);
        end
        
        function centroids = getCentroids(p)
            centroids = p.candidateSpotsAndCentroids.getCentroids();
        end
        
        function spotToCentroidMapping = getSpotToCentroidMapping(p, channelName)
            candidates = p.candidateSpotsAndCentroids.getSpots(channelName);
            candidatesToCentroidMapping = ...
                p.candidateSpotsAndCentroids.getSpotToCentroidMapping(channelName);
            
            threshold = p.thresholdsHolder.getThreshold(channelName);
            spotToCentroidMapping = candidatesToCentroidMapping(...
                candidates.intensities > threshold);
        end
        
        function [numSpotsForCentroids, spotToCentroidMapping] = ...
                getNumSpotsForCentroids(p, channelName)
            spotToCentroidMapping = p.getSpotToCentroidMapping(channelName);
            numSpotsForCentroids = dentist.utils.occurrencesOfIntegersUpToN(...
                spotToCentroidMapping, length(p.getCentroids()));
        end
        
        function channelNames = get.channelNames(p)
            channelNames = p.candidateSpotsAndCentroids.channelNames;
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
end

