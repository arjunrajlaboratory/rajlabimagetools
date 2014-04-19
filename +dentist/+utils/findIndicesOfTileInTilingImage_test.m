standardImageWidth = 1024;
standardImageHeight = 768;
numPixelOverlap = 103;
args = {standardImageWidth, standardImageHeight, numPixelOverlap};

tile = dentist.utils.TilePosition(3,4);
tile = tile.goToEdge('left');
tile = tile.goToEdge('up');
[xl, xh, yl, yh] = dentist.utils.findIndicesOfTileInTilingImage(tile, args{:});
assert(xl == 1); assert(xh == 921)
assert(yl == 1); assert(yh == 665)
assert(yh - yl == 664)

tile = tile.getNeighbor('down');
[xl, xh, yl, yh] = dentist.utils.findIndicesOfTileInTilingImage(tile, args{:});
assert(xl == 1); assert(xh == 921)
assert(yl == 666); assert(yh == 1330)
assert(yh - yl == 664)

tile = tile.getNeighbor('down');
[xl, xh, yl, yh] = dentist.utils.findIndicesOfTileInTilingImage(tile, args{:});
assert(xl == 1); assert(xh == 921)
assert(yl == 1331); assert(yh == 2098)
assert(yh - yl == 767)

tile = tile.getNeighbor('right');
[xl, xh, yl, yh] = dentist.utils.findIndicesOfTileInTilingImage(tile, args{:});
assert(xl == 922); assert(xh == 1842)
assert(yl == 1331); assert(yh == 2098)
assert(xh - xl == 920)

tile = tile.goToEdge('right');
[xl, xh, yl, yh] = dentist.utils.findIndicesOfTileInTilingImage(tile, args{:});
assert(xl == 2764); assert(xh == 3787)
assert(yl == 1331); assert(yh == 2098)
assert(xh - xl == 1023)
