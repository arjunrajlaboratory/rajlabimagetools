dentist.tests.cleanupForTests;

x = [1 1 1]';
y = [2 30 4]';
intensities = [10 11 12]';

mySpots = dentist.utils.Spots(x, y, intensities);
assert(all(mySpots.xPositions == [1 1 1]'))
assert(all(mySpots.yPositions == [2 30 4]'))
assert(all(mySpots.intensities == [10 11 12]'))

% coerces inputs to column vectors
mySpots = dentist.utils.Spots(x', y', intensities');
assert(all(mySpots.xPositions == [1 1 1]'))
assert(all(mySpots.yPositions == [2 30 4]'))
assert(all(mySpots.intensities == [10 11 12]'))

mySpotsInd = mySpots.subsetByIndices([1 1 3]);
assert(all(mySpotsInd.xPositions == [1 1 1]'));
assert(all(mySpotsInd.yPositions == [2 2 4]'));
assert(all(mySpotsInd.intensities == [10 10 12]'));

% indices can be specified as a column too.
mySpotsInd = mySpots.subsetByIndices([1 1 3]');
assert(all(mySpotsInd.xPositions == [1 1 1]'));
assert(all(mySpotsInd.yPositions == [2 2 4]'));
assert(all(mySpotsInd.intensities == [10 10 12]'));

appspots = concatenate(mySpots, mySpots);
assert(all(appspots.xPositions == [1 1 1 1 1 1]'));
assert(all(appspots.yPositions == [2 30 4 2 30 4]'));
assert(all(appspots.intensities == [10 11 12 10 11 12]'));

