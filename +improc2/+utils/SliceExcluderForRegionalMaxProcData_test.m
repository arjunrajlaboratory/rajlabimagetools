improc2.tests.cleanupForTests;

fakeRegMaxProcData = struct();
irrelevantLength = 5;
nSlices = 30;
fakeRegMaxProcData.imageSize = [irrelevantLength irrelevantLength nSlices];
fakeRegMaxProcData.excludedSlices = [13, 18];

procDataHolder = improc2.tests.MockProcessorDataHolder(fakeRegMaxProcData);


theseAreTheExcludedSlicesInProcData = @(sliceNumbers) isequal(...
    sort(sliceNumbers(:)), ...
    sort(procDataHolder.processorData.excludedSlices(:)));

x = improc2.utils.SliceExcluderForRegionalMaxProcData(procDataHolder);

assert(theseAreTheExcludedSlicesInProcData([13, 18]))



x.clearExclusionsAndExcludeSlicesStartingFrom(20)
assert(theseAreTheExcludedSlicesInProcData(20:nSlices))

x.clearExclusionsAndExcludeSlicesUpTo(5)
assert(theseAreTheExcludedSlicesInProcData(1:5))

x.clearExclusions();
assert(theseAreTheExcludedSlicesInProcData([]))

greaterThanNumSlices = 40;
x.clearExclusionsAndExcludeSlicesUpTo(greaterThanNumSlices)
assert(theseAreTheExcludedSlicesInProcData(1:nSlices))

lessThanMinimum = -4;
x.clearExclusionsAndExcludeSlicesStartingFrom(lessThanMinimum)
assert(theseAreTheExcludedSlicesInProcData(1:nSlices))

x.clearExclusionsAndIncludeOnlyBetween(7, 15)
assert(theseAreTheExcludedSlicesInProcData([1:6, 16:nSlices]))

x.clearExclusionsAndIncludeOnlyBetween(lessThanMinimum, 15)
assert(theseAreTheExcludedSlicesInProcData(16:nSlices))

x.clearExclusionsAndIncludeOnlyBetween(7, greaterThanNumSlices)
assert(theseAreTheExcludedSlicesInProcData(1:6))

x.clearExclusionsAndIncludeOnlyBetween(7, 7)
assert(theseAreTheExcludedSlicesInProcData([1:6, 8:nSlices]))

improc2.tests.shouldThrowError( @() x.clearExclusionsAndIncludeOnlyBetween(8, 7))