dentist.tests.cleanupForTests;

x = [1 1 1]';
y = [2 30 4]';
intensities = [10 11 12]';

mySpots = dentist.utils.DeleteableSpots(x,y,intensities);

subsTest = mySpots.subsetByIndices([1 1 3]);
assert(all(subsTest.xPositions == [1 1 1]'));
assert(all(subsTest.yPositions == [2 2 4]'));

delTest = mySpots.deleteByIndices(2);
assert(all(delTest.yPositions == [2 4]'))
assert(all(delTest.intensities == [10 12]'))

delTest2 = delTest.deleteByIndices(2);
assert(all(delTest2.yPositions == [2]))
assert(all(delTest2.intensities == [10]))

undelTest = delTest2.unDeleteAll();
assert(all(undelTest.yPositions == [2 30 4]'))
assert(all(undelTest.intensities == [10 11 12]'))

subsTest = delTest.subsetByIndices([2]);
assert(all(subsTest.yPositions == [4]))
% you cannot recover deleted parts after subsetByIndex.
undelAfterSubsTest = subsTest.unDeleteAll();
assert(all(undelAfterSubsTest.yPositions == [4]))

concspots = concatenate(delTest2, subsTest);
assert(all(concspots.yPositions == [2,4]'))
% concatenation keeps track of deleteable parts
concspots = concspots.unDeleteAll;
assert(all(concspots.yPositions == [2,30,4,4]'))
