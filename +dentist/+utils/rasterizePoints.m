function [im, hasPointsMask] = rasterizePoints(points, valueToAddAtPoint, ...
        widthAndHeightOfPointsDomain, widthAndHeightOfDesiredImage, ...
        aggregationFUNC)
    
    if nargin < 5
        aggregationFUNC = @sum;
    end
    
    originalImageWidth = widthAndHeightOfPointsDomain(1);
    originalImageHeight = widthAndHeightOfPointsDomain(2);
    
    desiredImageWidth = widthAndHeightOfDesiredImage(1);
    desiredImageHeight = widthAndHeightOfDesiredImage(2);
    
    Jcoords = scaleAndRoundCoordinates(points.xPositions, ...
        originalImageWidth, desiredImageWidth);
    Icoords = scaleAndRoundCoordinates(points.yPositions, ...
        originalImageHeight, desiredImageHeight);
    
    im = accumarray([Icoords, Jcoords], valueToAddAtPoint, ...
        [desiredImageHeight, desiredImageWidth], aggregationFUNC);
    
    numPointsIm = accumarray([Icoords, Jcoords], valueToAddAtPoint, ...
        [desiredImageHeight, desiredImageWidth], @length);
    
    hasPointsMask = numPointsIm > 0;
end

function scaled = scaleAndRoundCoordinates(raw, originalLength, desiredLength)
    scaled = (raw - 1) .* desiredLength / originalLength;
    scaled = 1 + floor(scaled);
    scaled = max(min(scaled, desiredLength), 1);
end

