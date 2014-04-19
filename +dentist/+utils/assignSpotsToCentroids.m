function [spotToCentroidMapping, spotsAssignedToACentroid] = assignSpotsToCentroids(...
            spots, centroids, maxDistance)
    [spotToCentroidMapping, distances] = knnsearch(...
        [centroids.xPositions, centroids.yPositions],...
        [spots.xPositions, spots.yPositions]);
    
    spotsToAssign = find(distances < maxDistance);
    spotsAssignedToACentroid = spots.subsetByIndices(spotsToAssign);
    spotToCentroidMapping = spotToCentroidMapping(spotsToAssign);
end

