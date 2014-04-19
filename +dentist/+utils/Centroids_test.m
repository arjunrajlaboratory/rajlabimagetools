clear; clear classes;

x = [1 1 1]';
y = [2 30 4]';

myCentroids = dentist.utils.Centroids(x, y);
assert(all(myCentroids.xPositions == [1 1 1]'));
assert(all(myCentroids.yPositions == [2 30 4]'));

% inputs are coerced to column vectors
myCentroids = dentist.utils.Centroids(x', y');
assert(all(myCentroids.xPositions == [1 1 1]'));
assert(all(myCentroids.yPositions == [2 30 4]'));

myCentroidsInd = myCentroids.subsetByIndices([1 1 3]');
assert(all(myCentroidsInd.xPositions == [1 1 1]'));
assert(all(myCentroidsInd.yPositions == [2 2 4]'));

concatCentroids = concatenate(myCentroids, myCentroids);
assert(all(concatCentroids.xPositions == [1 1 1 1 1 1]'));
assert(all(concatCentroids.yPositions == [2 30 4 2 30 4]'));


