mockObjectWithTilingImageInfo = struct('standardImageSize', [1024, 1024], ...
'numPixelOverlap', 103, 'Ncols', 4, 'Nrows', 3);

imWidth = (4 - 1) * (1024 - 103) + 1024;
imHeight = (3 - 1) * (1024 - 103) + 1024;

[w, h] = dentist.utils.computeTiledImageWidthAndHeight(mockObjectWithTilingImageInfo);

assert( w == imWidth && h == imHeight);

wh = dentist.utils.computeTiledImageWidthAndHeight(mockObjectWithTilingImageInfo);

assert(wh(1) == imWidth);
assert(wh(2) == imHeight);
