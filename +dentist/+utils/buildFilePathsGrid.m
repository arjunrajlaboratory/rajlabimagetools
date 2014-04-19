function filePaths = buildFilePathsGrid(dirPath, nameExt, foundChannels, ...
    Nrows, Ncols, nextFileDirection, secondaryDirection, snakeOrNoSnake)

assert(ismember(nextFileDirection, {'up','down','left','right'}), ...
    'unrecognized nextFileDirection. Valid values: up down left right')
assert(ismember(secondaryDirection, {'up','down','left','right'}), ...
    'unrecognized secondaryDirection. Valid values: up down left right')
assert(ismember(snakeOrNoSnake, {'snake', 'nosnake'}), ...
    'Specify snaking condition as: snake OR nosnake')

tile = initializeTilePosition(Nrows, Ncols, nextFileDirection, ...
    secondaryDirection);

filePaths = cell(Nrows,Ncols,numel(foundChannels));
currentFileNum = 1;

while true
    filePaths = addFilePathsAtTile(filePaths, tile, currentFileNum, dirPath, nameExt, foundChannels);
    currentFileNum = currentFileNum + 1;
    if tile.hasNeighbor(nextFileDirection)
        tile = tile.getNeighbor(nextFileDirection);
    else
        if tile.hasNeighbor(secondaryDirection)
            tile = tile.getNeighbor(secondaryDirection);
            switch snakeOrNoSnake
                case 'snake'
                    nextFileDirection = oppositeOf(nextFileDirection);
                case 'nosnake'
                    tile = tile.goToEdge(oppositeOf(nextFileDirection));
            end
        else
            break;
        end
    end
end

end




function filePaths = addFilePathsAtTile(filePaths, tile, currentFileNum, dirPath, nameExt, foundChannels)
    fileNumString = sprintf('%03d', currentFileNum);
    row = tile.row;
    col = tile.col;
        
    pathIndex = 1;
    for channelIndex = 1:length(foundChannels)
        channelName = foundChannels{channelIndex};
        filePath = strcat(dirPath, filesep, channelName, fileNumString, nameExt);
        filePaths{row, col, pathIndex} = filePath;
        pathIndex = pathIndex + 1;
    end
    
end


function tile = initializeTilePosition(Nrows, Ncols, nextFileDirection, secondaryDirection)
tile = dentist.utils.TilePosition(Nrows, Ncols);

if any(strcmp({nextFileDirection, secondaryDirection}, 'right'))
    tile = tile.goToEdge('left');
else
    tile = tile.goToEdge('right');
end

if any(strcmp({nextFileDirection, secondaryDirection}, 'down'))
    tile = tile.goToEdge('top');
else
    tile = tile.goToEdge('bottom');
end

end

function oppositeDirection = oppositeOf(direction)
switch direction
    case 'down'
        oppositeDirection = 'up';
    case 'up'
        oppositeDirection = 'down';
    case 'left'
        oppositeDirection = 'right';
    case 'right'
        oppositeDirection = 'left';
    otherwise
        error('Do not know the opposite of the input')
end
end


