function [varargout] = computeTiledImageWidthAndHeight(objectWithTilingImageInfo)
    imageSize = objectWithTilingImageInfo.standardImageSize;
    numPixelOverlap = objectWithTilingImageInfo.numPixelOverlap;
    Nrows = objectWithTilingImageInfo.Nrows;
    Ncols = objectWithTilingImageInfo.Ncols;
    imageWidth = Ncols * imageSize(:,2) ...
        - (Ncols - 1) * numPixelOverlap;
    imageHeight = Nrows * imageSize(:,1) ...
        - (Nrows - 1) * numPixelOverlap;
    
    % this helps it run faster on big scans
    %imageHeight = imageHeight*0.1;
    %imageWidth = imageWidth*0.1
    
    if nargout == 1
        varargout{1} = [imageWidth, imageHeight];
    elseif nargout == 2
        varargout{1} = imageWidth;
        varargout{2} = imageHeight;
    end
end
