classdef DeleteableSpotsAndCentroids < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        originalSpotsAndCentroids
        centroidsDeletionMask
        spotsDeletionMasks
    end
    
    properties (Dependent = true)
        channelNames
    end
    
    methods
        function p = DeleteableSpotsAndCentroids(spotsAndCentroids)
            p.originalSpotsAndCentroids = spotsAndCentroids;
            p.setMasksToNoDeletions();
        end
        
        function spots = getSpots(p, channelName)
            spots = p.originalSpotsAndCentroids.getSpots(channelName);
            notDeleted = ~ p.spotsDeletionMasks.getByChannelName(channelName);
            spots = spots.subsetByIndices(notDeleted);
        end
        
        function centroids = getCentroids(p)
            centroids = p.originalSpotsAndCentroids.getCentroids();
            notDeleted = ~ p.centroidsDeletionMask;
            centroids = centroids.subsetByIndices(notDeleted);
        end
        
        function spotToCentroidMapping = getSpotToCentroidMapping(p, channelName)
            spotToOriginalCentroidMapping = ...
                p.originalSpotsAndCentroids.getSpotToCentroidMapping(...
                channelName);
            deleted = p.spotsDeletionMasks.getByChannelName(channelName);
            spotToOriginalCentroidMapping(deleted) = [];
            spotToCentroidMapping = p.translateFromOriginalCentroidIndex(...
                spotToOriginalCentroidMapping);
        end
        
        function [numSpotsForCentroids, spotToCentroidMapping] = ...
                getNumSpotsForCentroids(p, channelName)
            spotToCentroidMapping = p.getSpotToCentroidMapping(channelName);
            numSpotsForCentroids = dentist.utils.occurrencesOfIntegersUpToN(...
                spotToCentroidMapping, length(p.getCentroids()));
        end
       
        function channelNames = get.channelNames(p)
            channelNames = p.originalSpotsAndCentroids.channelNames;
        end
        
        function deleteByXYFilter(p, vectorizedTwoArgumentIndicatorFUNC)
            centroids = p.originalSpotsAndCentroids.getCentroids();
            toDelete = vectorizedTwoArgumentIndicatorFUNC(...
                centroids.xPositions, centroids.yPositions);
            p.centroidsDeletionMask(toDelete) = true;
            p.deleteSpotsByMappedCentroid(find(toDelete))
            p.deleteSpotsByXYFilter(vectorizedTwoArgumentIndicatorFUNC)
        end
        
        %untested
        function setDeletionsToMatchXYFilter(p, vectorizedTwoArgumentIndicatorFUNC)
            p.unDeleteAll();
            p.deleteByXYFilter(vectorizedTwoArgumentIndicatorFUNC);
        end
        
        function unDeleteAll(p)
            p.setMasksToNoDeletions();
        end
        
    end
    
    methods (Access = private)
        
        function deleteSpotsByXYFilter(p, vectorizedTwoArgumentIndicatorFUNC)
            for channelName = p.channelNames;
                spots = p.originalSpotsAndCentroids.getSpots(channelName);
                toDelete = vectorizedTwoArgumentIndicatorFUNC(...
                    spots.xPositions, spots.yPositions);
                spotsMask = p.spotsDeletionMasks.getByChannelName(channelName);
                spotsMask(toDelete) = true;
                p.spotsDeletionMasks = ...
                    p.spotsDeletionMasks.setByChannelName(spotsMask, channelName);
            end
        end
        
        function deleteSpotsByMappedCentroid(p, originalCentroidIndices)
            for channelName = p.channelNames
                map = p.originalSpotsAndCentroids.getSpotToCentroidMapping(channelName);
                toDelete = ismember(map, originalCentroidIndices);
                spotsMask = p.spotsDeletionMasks.getByChannelName(channelName);
                spotsMask(toDelete) = true;
                p.spotsDeletionMasks = ...
                    p.spotsDeletionMasks.setByChannelName(spotsMask, channelName);
            end
        end
        
        function setMasksToNoDeletions(p)
            centroidsLength = length(p.originalSpotsAndCentroids.getCentroids());
            p.centroidsDeletionMask = false([1 centroidsLength]);
            
            channelNames = p.channelNames;
            p.spotsDeletionMasks = dentist.utils.ChannelArray(channelNames);
            
            for channelName = channelNames;
                spotsLength = length(p.originalSpotsAndCentroids.getSpots(...
                    channelName));
                delMask = false([1 spotsLength]);
                p.spotsDeletionMasks = p.spotsDeletionMasks.setByChannelName(...
                    delMask, channelName);
            end
        end
        
        function indexInDeleted = translateFromOriginalCentroidIndex(p, ...
                indexInOriginal)
            deletedCentsLength = sum( ~ p.centroidsDeletionMask);
            originalLength = length(p.originalSpotsAndCentroids.getCentroids());
            deletedCentIndexForOriginalIndex = zeros(originalLength, 1);
            deletedCentIndexForOriginalIndex(~ p.centroidsDeletionMask) = ...
                1:deletedCentsLength;
            indexInDeleted = deletedCentIndexForOriginalIndex(indexInOriginal);
        end
    end
    
    
end

