
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
rightUL = [0, 11];
downUL = [11, 2];
numTilesR = 3;
numTilesC = 3;
[tileSize, grid] = shift.process.getGridAndTileSize(imageSize, rightUL,...
    downUL, numTilesR, numTilesC);
assert(all(tileSize == [10, 10]),'d');
assert(all(all(grid(:,:,1) == [1 0 -1; 11 10 9; 21 20 19])),'e')
assert(all(all(grid(:,:,2) == [1 11 21; 2 12 22; 3 13 23])),'f')
