improc2.tests.cleanupForTests;


mask1 = false(30,30);
mask1(5:9, 9:13) = true;

[x, y] = improc2.utils.getCenterOfConnectedBWImage(mask1);

assert(x == 11)
assert(y == 7)