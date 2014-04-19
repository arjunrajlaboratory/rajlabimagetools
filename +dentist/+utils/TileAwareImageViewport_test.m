% construction test
dentist.tests.cleanupForTests;

mockImageProvider = struct('standardImageSize', [1024 1024], ...
    'numPixelOverlap', 103, 'Nrows', 3, 'Ncols', 4);

imWidth = 3*(1024-103) + 1024;
imHeight = 2*(1024-103) + 1024;

viewport = dentist.utils.TileAwareImageViewport(mockImageProvider);

assert(viewport.imageWidth == imWidth)
assert(viewport.imageHeight == imHeight)

assert(viewport.ulCornerXPosition == 1)
assert(viewport.ulCornerYPosition == 1)

assert(viewport.width == viewport.imageWidth)
assert(viewport.height == viewport.imageHeight)

assert(viewport.centerXPosition == ...
    viewport.ulCornerXPosition + (viewport.width-1)/2);
assert(viewport.centerYPosition == ...
    viewport.ulCornerYPosition + (viewport.height-1)/2);

%% containsTile 
dentist.tests.cleanupForTests;
Nrows = 3; Ncols = 4;
mockImageProvider = struct('standardImageSize', [1024 1024], ...
    'numPixelOverlap', 103, 'Nrows', Nrows, 'Ncols', Ncols);
viewport = dentist.utils.TileAwareImageViewport(mockImageProvider);

tile = dentist.utils.TilePosition(Nrows, Ncols);
tile = tile.goToEdge('left');
tile = tile.goToEdge('top');
assert(viewport.containsTile(tile));

viewport = viewport.setWidth(1024);
viewport = viewport.setHeight(1024);
assert(~ viewport.containsTile(tile));

tile = tile.getNeighbor('right');
assert(~ viewport.containsTile(tile));

tile = tile.getNeighbor('right');
assert(~ viewport.containsTile(tile));

tile = tile.getNeighbor('down');
assert(viewport.containsTile(tile));

tile = tile.getNeighbor('left');
assert(viewport.containsTile(tile));

tile = tile.getNeighbor('down');
assert(viewport.containsTile(tile));
%% containsTile Bug
dentist.tests.cleanupForTests;
Nrows = 2; Ncols = 2;
mockImageProvider = struct('standardImageSize', [1024 1024], ...
    'numPixelOverlap', 103, 'Nrows', Nrows, 'Ncols', Ncols);
viewport = dentist.utils.TileAwareImageViewport(mockImageProvider);
viewport = viewport.setWidth(638);
viewport = viewport.setHeight(638);
viewport = viewport.tryToPlaceULCornerAtXPosition(1307);
viewport = viewport.tryToPlaceULCornerAtYPosition(362);
tile = dentist.utils.TilePosition(Nrows, Ncols);

assert(~ viewport.containsTile(tile))
assert(viewport.containsTile(tile.getNeighbor('right')))
assert(viewport.containsTile(tile.getNeighbor('down-right')))
assert(~ viewport.containsTile(tile.getNeighbor('down')))

%% findTileAtCenter

dentist.tests.cleanupForTests;
Nrows = 3; Ncols = 4;
mockImageProvider = struct('standardImageSize', [1024 1024], ...
    'numPixelOverlap', 103, 'Nrows', Nrows, 'Ncols', Ncols);
viewport = dentist.utils.TileAwareImageViewport(mockImageProvider);

viewport = viewport.setWidth(5);
viewport = viewport.setHeight(5);

viewport = viewport.tryToCenterAtXPosition(1);
viewport = viewport.tryToCenterAtYPosition(1);

tile = viewport.findTileAtCenter();
assert(tile.row == 1 && tile.col == 1);

viewport = viewport.tryToCenterAtXPosition(1024 - 103);
tile = viewport.findTileAtCenter();
assert(tile.row == 1 && tile.col == 1);

viewport = viewport.tryToCenterAtXPosition(1024 - 103 + 1);
tile = viewport.findTileAtCenter();
assert(tile.row == 1 && tile.col == 2);

viewport = viewport.tryToCenterAtXPosition(viewport.imageWidth);
tile = viewport.findTileAtCenter();
assert(tile.row == 1 && tile.col == Ncols);

viewport = viewport.tryToCenterAtYPosition(1024 - 103);
tile = viewport.findTileAtCenter();
assert(tile.row == 1 && tile.col == Ncols);

viewport = viewport.tryToCenterAtYPosition(1024 - 103 + 1);
tile = viewport.findTileAtCenter();
assert(tile.row == 2 && tile.col == Ncols);

viewport = viewport.tryToCenterAtYPosition(viewport.imageHeight);
tile = viewport.findTileAtCenter();
assert(tile.row == Nrows && tile.col == Ncols);
