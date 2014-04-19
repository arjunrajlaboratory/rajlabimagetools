function [xLow, xHigh, yLow, yHigh] = findIndicesOfTileInTilingImage(tile, ...
        standardImageWidth, standardImageHeight, numPixelOverlap)
    
    xLow = (tile.col - 1) * (standardImageWidth - numPixelOverlap) + 1;
    if tile.hasNeighbor('right')
        xHigh = xLow + (standardImageWidth - numPixelOverlap) - 1;
    else
        xHigh = xLow + standardImageWidth - 1;
    end
    yLow = (tile.row - 1) * (standardImageHeight - numPixelOverlap) + 1;
    if tile.hasNeighbor('down')
        yHigh = yLow + (standardImageHeight - numPixelOverlap) - 1;
    else
        yHigh = yLow + standardImageHeight - 1;
    end
end

