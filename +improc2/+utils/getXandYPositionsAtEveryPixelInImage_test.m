improc2.tests.cleanupForTests;

img = rand(3,2);

[Xs, Ys] = improc2.utils.getXandYPositionsAtEveryPixelInImage(img);

expectedXs = [1 2; 1 2; 1 2];
expectedYs = [1 1; 2 2; 3 3];

assert(isequal(Xs, expectedXs))
assert(isequal(Ys, expectedYs))

