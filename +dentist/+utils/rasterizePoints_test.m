dentist.tests.cleanupForTests;

xs = [1, 101, 300, 400];
ys = [1, 150, 150, 500];

points = dentist.utils.Centroids(xs,ys);

values = [1, 2, 3, 4];

widthAndHeightOfPointRange = [400, 500];
widthAndHeightOfDesiredImage = [4, 5];

expectedIm = zeros(5, 4);
expectedIm(1,1) = 1;
expectedIm(2,2) = 2;
expectedIm(2,3) = 3;
expectedIm(5,4) = 4;

expectedMask = false(5, 4);
expectedMask(1,1) = true;
expectedMask(2,2) = true;
expectedMask(2,3) = true;
expectedMask(5,4) = true;

[im, hasPointsMask] = dentist.utils.rasterizePoints(points, values, ...
    widthAndHeightOfPointRange, widthAndHeightOfDesiredImage);

assert(all(im(:) == expectedIm(:)));

assert(islogical(hasPointsMask))
assert(all(expectedMask(:) == hasPointsMask(:)))

%%

xs = [100, 101, 150, 200];
ys = [100, 101, 150, 200];

points = dentist.utils.Centroids(xs,ys);

values = [1, 2, 3, 4];

widthAndHeightOfPointRange = [400, 500];
widthAndHeightOfDesiredImage = [4, 5];

expectedIm = zeros(5, 4);
expectedIm(1,1) = 1;
expectedIm(2,2) = 2 + 3 + 4;

expectedMask = false(5, 4);
expectedMask(1,1) = true;
expectedMask(2,2) = true;

[im, hasPointsMask] = dentist.utils.rasterizePoints(points, values, widthAndHeightOfPointRange, ...
    widthAndHeightOfDesiredImage);

assert(all(im(:) == expectedIm(:)));
assert(islogical(hasPointsMask))
assert(all(expectedMask(:) == hasPointsMask(:)))

%%

im = dentist.utils.rasterizePoints(points, values, widthAndHeightOfPointRange, ...
    widthAndHeightOfDesiredImage, @max);

expectedIm = zeros(5, 4);
expectedIm(1,1) = 1;
expectedIm(2,2) = 4;

assert(all(im(:) == expectedIm(:)));


im = dentist.utils.rasterizePoints(points, values, widthAndHeightOfPointRange, ...
    widthAndHeightOfDesiredImage, @min);

expectedIm = zeros(5, 4);
expectedIm(1,1) = 1;
expectedIm(2,2) = 2;

assert(all(im(:) == expectedIm(:)));
