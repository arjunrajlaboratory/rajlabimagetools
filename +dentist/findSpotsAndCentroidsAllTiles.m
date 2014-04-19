function [spots, centroids, frequencyTables, thresholdsArray] = findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag)
    if nargin < 2
        verboseFlag = false;
    end
    
    Nrows = imageProvider.Nrows;
    Ncols = imageProvider.Ncols;
    fishChannelNames = imageProvider.availableFishChannels;
    
    spotsArray = dentist.utils.PositionAndChannelArray(Nrows, Ncols, ...
        fishChannelNames);
    thresholdsArray = dentist.utils.PositionAndChannelArray(Nrows, Ncols, ...
        fishChannelNames);
    frequencyTableArray = dentist.utils.PositionAndChannelArray(Nrows, Ncols, ...
        fishChannelNames);
    centroidsArray = dentist.utils.PositionArray(Nrows, Ncols);
    
    tiles = dentist.utils.TileIterator(Nrows, Ncols);
    while tiles.hasNext()
        tile = tiles.next();
        imageProvider.goToTile(tile);
        
        [spotsInTile, frequencyTablesInTile, thresholdsByChannel] =...
            dentist.findSpotsInTile(imageProvider, verboseFlag);
        for channelName = spotsInTile.channelNames
            spotsInTileInChannel = spotsInTile.getByChannelName(channelName);
            spotsInTileInChannel = translateToAbsoluteCoordinates(...
                spotsInTileInChannel, tile, imageProvider);
            spotsInTile = spotsInTile.setByChannelName(spotsInTileInChannel, channelName);
        end

        centroidsInTile = dentist.findCentroidsInImage(imageProvider, verboseFlag);
        centroidsInTile = translateToAbsoluteCoordinates(centroidsInTile,...
            tile, imageProvider);
        
        spotsArray = spotsArray.setByPosition(spotsInTile, tile);
        thresholdsArray = thresholdsArray.setByPosition(thresholdsByChannel,tile);
        frequencyTableArray = frequencyTableArray.setByPosition(frequencyTablesInTile,tile);
        centroidsArray = centroidsArray.setByPosition(centroidsInTile, tile);
    end
    
    centroidsArray = removeDuplicateCentroids(centroidsArray);
    centroids = ...
        centroidsArray.aggregateAllPositions(@(a,b) a.concatenate(b));
    spots = ...
        spotsArray.aggregateAllPositions(@(a,b) a.concatenate(b));
    frequencyTables = ...
        frequencyTableArray.aggregateAllPositions(@(a,b) a.add(b));
end


function object = translateToAbsoluteCoordinates(object, tile, imageProvider)
    imageSize = imageProvider.standardImageSize;
    numPixelOverlap = imageProvider.numPixelOverlap;
   object.xPositions = object.xPositions + ((tile.col - 1) *...
       (imageSize(2) - numPixelOverlap));
   object.yPositions = object.yPositions + ((tile.row - 1) *...
       (imageSize(1) - numPixelOverlap));
end

function centroidsArray = removeDuplicateCentroids(centroidsArray, minPixelDistance)
    if nargin < 2
        minPixelDistance = 5;
    end
    
    tiles = dentist.utils.TileIterator(centroidsArray.Nrows, centroidsArray.Ncols);
    while tiles.hasNext()
       tile = tiles.next();
       centroidsCurrent = centroidsArray.getByPosition(tile);
       for neighborDirection = {'right', 'down', 'down-right'}
           if tile.hasNeighbor(neighborDirection)
               neighborCentroids = centroidsArray.getByPosition(...
                   tile.getNeighbor(neighborDirection));
               centroidsCurrent = deleteDuplicates(minPixelDistance,...
                   centroidsCurrent, neighborCentroids);
           end
       end
       centroidsArray = centroidsArray.setByPosition(centroidsCurrent, tile);
    end
end

% Removes from centroids1 that are too close to positions in
% centroids2
function centroids = deleteDuplicates(minPixelDistance,centroids1, centroids2)
    if (nargin  == 2)
        centroids2 = centroids1;
    end
    positions1 = [centroids1.xPositions,...
        centroids1.yPositions];
    positions2 = [centroids2.xPositions,...
        centroids2.yPositions];
    % Take pairwise distance
    dist = pdist2(positions1, positions2);
    if (nargin == 2)
        diagonalMask = eye(size(dist));
        dist(diagonalMask) = inf;
    end
    % Take minimum of each row
    minDist = min(dist, [], 2);
    deleteMask = minDist < minPixelDistance;
    indices = find(~deleteMask);
    centroids = centroids1.subsetByIndices(indices);
end


