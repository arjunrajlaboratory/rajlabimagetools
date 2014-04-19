classdef ThumbnailMaker < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        centroidsAndNumSpotsSource
        numSpotsToColorTranslator
        imageWidth
        imageHeight
        channelName
        prioritizeHighOrLow = 'high';
        thumbnailWidth = 1000;
        thumbnailHeight = 1000;
        expandedPixelSideLengthInImage = 101;
        rgbImage
    end
    
    
    
    methods
        function p = ThumbnailMaker(resources)
            p.channelName                   = resources.channelName;
            p.centroidsAndNumSpotsSource    = resources.centroidsAndNumSpotsSource;
            p.numSpotsToColorTranslator     = resources.numSpotsToColorTranslator;
            p.imageWidth                    = resources.imageWidth;
            p.imageHeight                   = resources.imageHeight;
        end
        
        function setThumbnailWidthAndHeight(p, width, height)
            p.thumbnailWidth = width;
            p.thumbnailHeight = height;
        end
        
        function setPixelExpansionSize(p, expandedPixelSideLengthInImage)
            p.expandedPixelSideLengthInImage = expandedPixelSideLengthInImage;
        end
        
        function prioritizeLowExpressers(p)
            p.prioritizeHighOrLow = 'low';
        end
        
        function prioritizeHighExpressers(p)
            p.prioritizeHighOrLow = 'high';
        end
        
        function makeAndStore(p)
            [numSpotsImage, hasCentroidsMask] = p.makeNumSpotsImage();
            [pixelExpandedImage, noSignalMask] = ...
                p.expandPixels(numSpotsImage, hasCentroidsMask);
            p.rgbImage = p.colorNumSpotsImage(pixelExpandedImage, noSignalMask);
        end
        
        function rgbImage = getRGBImage(p)
            rgbImage = p.rgbImage;
        end
    end
    
    methods (Access = private)
        function [numSpotsImage, hasCentroidsMask] = makeNumSpotsImage(p)
            centroids = p.centroidsAndNumSpotsSource.getCentroids();
            numSpots = p.centroidsAndNumSpotsSource.getNumSpotsForCentroids(p.channelName);
            switch p.prioritizeHighOrLow
                case 'high'
                    aggregationFUNC = @max;
                case 'low'
                    aggregationFUNC = @min;
            end
            widthAndHeightOfPointsDomain = [p.imageWidth, p.imageHeight];
            widthAndHeightOfDesiredImage = [p.thumbnailWidth, p.thumbnailHeight];
            [numSpotsImage, hasCentroidsMask] = dentist.utils.rasterizePoints(...
                centroids, numSpots, widthAndHeightOfPointsDomain, ...
                widthAndHeightOfDesiredImage, aggregationFUNC);
        end
        
        function [pixelExpandedImage, hasNoSignalDespiteExpansion] = expandPixels(p, ...
                numSpotsImage, hasCentroidsMask)
            
            blownUpPointSizeInThumbnail = p.expandedPixelSideLengthInImage * ...
                mean(p.thumbnailWidth, p.thumbnailHeight) /...
                mean(p.imageWidth, p.imageHeight);
            blownUpPointSizeInThumbnail = 1 + floor(blownUpPointSizeInThumbnail);
            
            pixelExpandedImage = dentist.utils.blowUpPixels(...
                numSpotsImage, blownUpPointSizeInThumbnail, ...
                p.prioritizeHighOrLow, hasCentroidsMask);
            
            hasNoSignalDespiteExpansion = ~ dentist.utils.blowUpPixels(...
                double(hasCentroidsMask), blownUpPointSizeInThumbnail, ...
                p.prioritizeHighOrLow);
        end
        
        function rgbImage = colorNumSpotsImage(p, numSpotsImage, noSignalMask)
            redImage = zeros(size(numSpotsImage));
            greenImage = zeros(size(numSpotsImage));
            blueImage = zeros(size(numSpotsImage));
            
            linearIndicesOfPointsWithSignal = ~ noSignalMask(:);
            rgbAtPointsWithSignal = p.numSpotsToColorTranslator.translateToRGB(...
                numSpotsImage(linearIndicesOfPointsWithSignal));
            
            redImage(linearIndicesOfPointsWithSignal) = rgbAtPointsWithSignal(:,1);
            greenImage(linearIndicesOfPointsWithSignal) = rgbAtPointsWithSignal(:,2);
            blueImage(linearIndicesOfPointsWithSignal) = rgbAtPointsWithSignal(:,3);
            rgbImage = cat(3, redImage, greenImage, blueImage);
        end
    end
    
end

