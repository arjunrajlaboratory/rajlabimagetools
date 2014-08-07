
imageSize = [10, 10];
rightUL = [1, 11];
downUL = [11, 1];
numTilesR = 3;
numTilesC = 3;
[tileSize, grid] = shift.process.getGridAndTileSize(imageSize, rightUL,...
    downUL, numTilesR, numTilesC);
assert(all(tileSize == [10, 10]),'a');
assert(all(all(grid(:,:,1) == [1 1 1; 11 11 11; 21 21 21])),'b')
assert(all(all(grid(:,:,2) == [1 11 21; 1 11 21; 1 11 21])),'c')

imageSize = [10, 10];
rightUL = [1, 10];
downUL = [9, 1];
numTilesR = 3;
numTilesC = 3;
[tileSize, grid] = shift.process.getGridAndTileSize(imageSize, rightUL,...
    downUL, numTilesR, numTilesC);
assert(all(all(grid(:,:,1) == [1 1 1; 9 9 9; 17 17 17])),'e')
assert(all(all(grid(:,:,2) == [1 10 19; 1 10 19; 1 10 19])),'f')
