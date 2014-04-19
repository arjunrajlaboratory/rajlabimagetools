function thumbnail = makeRNADensityIntensityThumbnail(spotsAndCentroids, ...
        imageWidthAndHeight, channelName)
    
    thumbnailWidthAndHeight = [1000, 1000];
    blownUpPointSizeInImage = 201;
    
    spots = spotsAndCentroids.getSpots(channelName);
    [numSpotsForCentroids, spotToCentroidMapping] = ...
        spotsAndCentroids.getNumSpotsForCentroids(channelName);
    
    numSpotsAtAssignedCentroid = numSpotsForCentroids(spotToCentroidMapping(:));
    
    thumbnail = dentist.utils.rasterizePoints(spots, numSpotsAtAssignedCentroid, ...
        imageWidthAndHeight, thumbnailWidthAndHeight);
    
    blownUpPointSizeInThumbnail = blownUpPointSizeInImage * ...
        mean(thumbnailWidthAndHeight)/mean(imageWidthAndHeight);
    blownUpPointSizeInThumbnail = 1 + floor(blownUpPointSizeInThumbnail);
    
    thumbnail = dentist.utils.blowUpPixels(thumbnail, blownUpPointSizeInThumbnail);
    
end
