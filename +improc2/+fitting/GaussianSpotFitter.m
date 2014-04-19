classdef GaussianSpotFitter < handle
    
    properties
        xGuess = 0;
        xMaxDeviationFromGuess = Inf;
        
        yGuess = 0;
        yMaxDeviationFromGuess = Inf;
        
        sigmaGuess = 1;
        sigmaLimits = [0 Inf];
        
        amplitudeLimits = [0 Inf];
        offsetLimits = [-Inf Inf];
        
        halfLengthOfRegionToFit = 5;
        
        spotZPlane = 1;
    end
    
    properties (SetAccess = private)
        fitOptions
        img
        imWidth
        imHeight
        imgXs
        imgYs
    end
    
    methods
        function p = GaussianSpotFitter(img, fitOptions)
            if nargin < 2
                fitOptions = optimset('lsqcurvefit');
                fitOptions = optimset(fitOptions, 'Display', 'off');
            end
            p.fitOptions = fitOptions;
            p.img = img;
            p.imWidth = size(img, 2);
            p.imHeight = size(img, 1);
            [p.imgXs, p.imgYs] = improc2.utils.getXandYPositionsAtEveryPixelInImage(p.img);
        end
        
        function [fittedGaussian2dSpot, fittedBackgroundLevel] = fitSpot(p)
            
            croppedImg = p.cropMatrixToSpotNeighborhood(p.img(:, :, p.spotZPlane));
            croppedImg = im2double(croppedImg);
            croppedImgXs = p.cropMatrixToSpotNeighborhood(p.imgXs);
            croppedImgYs = p.cropMatrixToSpotNeighborhood(p.imgYs);
            
            amplitudeGuess = max(croppedImg(:));
            offsetGuess = median(croppedImg(:));
            
            parameterGuesses = [...
                amplitudeGuess, ...
                offsetGuess, ...
                1 / p.sigmaGuess, ...
                p.xGuess, ...
                p.yGuess];
            parameterLowerBounds = [...
                p.amplitudeLimits(1), ...
                p.offsetLimits(1), ...
                1 / p.sigmaLimits(2), ...
                p.xGuess - p.xMaxDeviationFromGuess, ...
                p.yGuess - p.yMaxDeviationFromGuess];
            parameterUpperBounds = [...
                p.amplitudeLimits(2), ...
                p.offsetLimits(2), ...
                1 / p.sigmaLimits(1), ...
                p.xGuess + p.xMaxDeviationFromGuess, ...
                p.yGuess + p.yMaxDeviationFromGuess];
            
            parameterBestFit = lsqcurvefit(@gaussian2dfunc, ...
                parameterGuesses, ...
                [croppedImgXs(:), croppedImgYs(:)], ...
                croppedImg(:), ...
                parameterLowerBounds, parameterUpperBounds, p.fitOptions);
            
            fittedGaussian2dSpot = improc2.fitting.Gaussian2dSpot(...
                parameterBestFit(4), ...
                parameterBestFit(5), ...
                1 / parameterBestFit(3), ...
                parameterBestFit(1), ...
                p.spotZPlane);
                
            fittedBackgroundLevel = parameterBestFit(2);
            
        end
        
    end
    
    methods (Access = private)
        function [croppedImg] = cropMatrixToSpotNeighborhood(p, img)
            xGuessPixel = getNearestPixelAndCoerceToDimension(p.xGuess, p.imWidth);
            yGuessPixel = getNearestPixelAndCoerceToDimension(p.yGuess, p.imHeight);
            neighborhoodBoundingBox = [...
                xGuessPixel - p.halfLengthOfRegionToFit, ...
                yGuessPixel - p.halfLengthOfRegionToFit, ...
                2 * p.halfLengthOfRegionToFit, ...
                2 * p.halfLengthOfRegionToFit];
            croppedImg = imcrop(img, neighborhoodBoundingBox);
        end
    end
end


function pixels = getNearestPixelAndCoerceToDimension(positions, lengthAlongThisDimension)
    pixels = min(lengthAlongThisDimension, max(1, round(positions)));
end




