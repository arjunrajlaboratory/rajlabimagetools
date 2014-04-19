function [fitResults] = fit2dGaussiansToImage(img, candidateXCoords, ...
    candidateYCoords, candidateZCoords, halfLengthOfRegionToFit, fitOptions)
    
    
    fitOptions = optimset('lsqcurvefit');
    fitOptions = optimset(fitOptions,'Display','off');
    
    imWidth = size(img, 2);
    imHeight = size(img, 1);
    
    candidateSpotNearestXPixel = getNearestPixelAndCoerceToDimension(candidateXCoords, imWidth);
    candidateSpotNearestYPixel = getNearestPixelAndCoerceToDimension(candidateYCoords, imHeight);
    
    [Xs, Ys] = getXandYPositionsAtEveryPixelInImage(imWidth, imHeight);
    
    numSpots = length(candidateXCoords);
    gaussianFitterTool = improc2.fitting.GaussianSpotFitter();
    
    gaussianFitterTool.sigmaGuess = 2;
    
    for currentSpot = 1:numSpots
        
        gaussianFitterTool.xGuess = candidateXCoords(currentSpot);
        gaussianFitterTool.yGuess = candidateYCoords(currentSpot);
        
        spotPlaneNumber = candidateZCoords(currentSpot);
        
        neighborhoodBoundingBox = [...
            spotJ - halfLengthOfRegionToFit, spotI - halfLengthOfRegionToFit, ...
            2 * halfLengthOfRegionToFit, 2 * halfLengthOfRegionToFit];
        
        imgNeighborhood = im2double(imcrop(img(:, :, spotK), neighborhoodBoundingBox));
        XsNeighborhood = double(imcrop(Xs, neighborhoodBoundingBox));
        YsNeighborhood = double(imcrop(Ys, neighborhoodBoundingBox));
        
        amplitudePrior.guess = max(imgNeighborhood(:));
        offsetPrior.guess = median(imgNeighborhood(:));
        XPrior = XPriors(currentSpot);
        YPrior = YPriors(currentSpot);
        
        parameterPriors = [amplitudePrior, offsetPrior, inverseSigmaPrior, XPrior, YPrior];
        predictors = [XsNeighborhood(:), YsNeighborhood(:)];
        signalToPredict = imgNeighborhood(:);
        
        bestFitParameterValues = lsqcurvefit(@gaussian2dfunc, [parameterPriors.guess], ...
            predictors, signalToPredict, ...
            [parameterPriors.lowerBound], ...
            [parameterPriors.upperBound], fitOptions);
        
        result.rawamp = img(spotI, spotJ, spotK);
    end
end




function 
