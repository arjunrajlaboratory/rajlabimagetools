improc2.tests.cleanupForTests;

x = improc2.utils.ZSlicer();

img = zeros(3,3,3);

img(2,2,1) = 1;
img(2,2,2) = 2;
img(2,2,3) = 3;

x.setSliceToTake(1)
sliced = x.sliceImage(img);
assert(all(size(sliced) == [3,3]))
assert(sliced(2,2) == 1)

x.setSliceToTake(2);
sliced = x.sliceImage(img);
assert(all(size(sliced) == [3,3]))
assert(sliced(2,2) == 2)

x.setSliceToTake(3);
sliced = x.sliceImage(img);
assert(all(size(sliced) == [3,3]))
assert(sliced(2,2) == 3)

points = [...
    10, 100, 1; ...
    11, 101, 1; ...
    20, 200, 2; ...
    30, 300, 3];
Xs = points(:,1); Ys = points(:,2); Zs = points(:,3);

x.setSliceToTake(1);
[slicedX, slicedY] = x.slicePoints(Xs, Ys, Zs);
assert(all(slicedX == [10 11]'))
assert(all(slicedY == [100 101]'))

x.setSliceToTake(3);
[slicedX, slicedY] = x.slicePoints(Xs, Ys, Zs);
assert(all(slicedX == 30))
assert(all(slicedY == 300))
