improc2.tests.cleanupForTests;


x = improc2.dataNodes.ImageObjectBaseData();
assert(isempty(x.imageFileMask))
assert(isstruct(x.metadata))
assert(isempty(fields(x.metadata)))

x.imageFileMask = [0 1; 0 0];
x.metadata.someProperty = true;

assert(isequal(x.imageFileMask, [0 1; 0 0]))
assert(x.metadata.someProperty)
