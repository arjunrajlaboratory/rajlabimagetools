improc2.tests.cleanupForTests;


x = improc2.dataNodes.ImageObjectBaseData();
assert(isempty(x.imageFileMask))
assert(isstruct(x.metadata))
assert(isempty(fields(x.metadata)))
assert(isempty(x.channelNames))

x.imageFileMask = [0 1; 0 0];
x.metadata.someProperty = true;
x.channelNames = {'cy', 'dapi'};

assert(isequal(x.imageFileMask, [0 1; 0 0]))
assert(x.metadata.someProperty)
assert(isequal(x.channelNames, {'cy', 'dapi'}))