function [tileSize, grid, numTilesR, numTilesC] = getGridAndTileSize(imageSize, rightUL,...
    downUL, numTilesR, numTilesC)
    %----------------------------------------------------------------------
    % Determine overlap in each direction
    overlapC = (imageSize(2) + 1) - rightUL(2);
    overlapR = (imageSize(1) + 1) - downUL(1);
    %----------------------------------------------------------------------
    % Figure out what sizeR (row_size of each new image should be)
    scanSizeR = ((imageSize(1) * numTilesR) - (overlapR * (numTilesR - 1)));
    numTilesR = ceil(scanSizeR/imageSize(1));
    tileSizeR = floor(scanSizeR/numTilesR);
    %----------------------------------------------------------------------
    % Figure out what size (col_size of each new image should be)
    scanSizeC = ((imageSize(2) * numTilesC) - (overlapC * (numTilesC - 1)));
    numTilesC = ceil(scanSizeC/imageSize(2));
    tileSizeC = floor(scanSizeC/numTilesC);
    %----------------------------------------------------------------------
    % Assign the absolute upper-left indices for each image into the cell
    % matrix 'grid'
    grid = zeros(numTilesR,numTilesC,2);
    for r = 1:numTilesR
        for c = 1:numTilesC
            rBegAbs = 1 + ((downUL(1) - 1) * (r - 1));
            cBegAbs = 1 + ((rightUL(2) - 1) * (c - 1));
            grid(r,c,:) = [rBegAbs,cBegAbs];
        end
    end
    tileSize = [tileSizeR, tileSizeC];
end