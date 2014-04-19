dentist.tests.cleanupForTests;

x = [1 1 1];
y = [2 30 4];

myCentroids = dentist.utils.DeleteableCentroids(x,y);

subsTest = myCentroids.subsetByIndices([1 1 3]);
assert(all(subsTest.xPositions == [1 1 1]'), 'xPos');
assert(all(subsTest.yPositions == [2 2 4]'), 'yPos');

delTest = myCentroids.deleteByIndices(2);
assert(all(delTest.yPositions == [2 4]'), 'yPos')
delTest2 = delTest.deleteByIndices(2);
assert(all(delTest2.yPositions == [2]), 'yPos')
undelTest = delTest2.unDeleteAll();
assert(all(undelTest.yPositions == [2 30 4]'))

subsTest = delTest.subsetByIndices([2]);
assert(all(subsTest.yPositions == [4]), 'yPos')
undelTest = subsTest.unDeleteAll();
assert(all(undelTest.yPositions == [4]))

conccentroids = concatenate(delTest2, subsTest);
assert(all(conccentroids.yPositions == [2,4]'))
conccentroids = conccentroids.unDeleteAll;
assert(all(conccentroids.yPositions == [2,30,4,4]'))
