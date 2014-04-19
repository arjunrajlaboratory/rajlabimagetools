function spotsAsPixels = make2dPixelatedRNASpotsMaskFromProcessor(...
        imageAndSpotCoordinatesProvidingProcessor, desiredWidthOfBlownUpPixel)
    
    imSize = size(imageAndSpotCoordinatesProvidingProcessor.getImage());
    width = imSize(2);
    height = imSize(1);
    
    [Ys, Xs, Zs] = imageAndSpotCoordinatesProvidingProcessor.getSpotCoordinates();
    intensities = ones(size(Ys));
    spots = dentist.utils.Spots(Xs, Ys, intensities);
    widthAndHeightOfPointsDomain = [width, height];
    widthAndHeightOfDesiredImage = [width, height];
    
    spotsAsPixels = dentist.utils.rasterizePoints(spots, spots.intensities, ...
        widthAndHeightOfPointsDomain, widthAndHeightOfDesiredImage);
    
    spotsAsPixels = min(spotsAsPixels, 1);
    spotsAsPixels = dentist.utils.blowUpPixels(spotsAsPixels, ...
        desiredWidthOfBlownUpPixel, 'high');
    spotsAsPixels = logical(spotsAsPixels);
    
end

