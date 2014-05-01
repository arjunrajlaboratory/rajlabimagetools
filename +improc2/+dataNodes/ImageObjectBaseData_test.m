improc2.tests.cleanupForTests;


x = improc2.dataNodes.ImageObjectBaseData();
assert(isempty(x.imageFileMask))

x.imageFileMask = [0 1; 0 0];

assert(isequal(x.imageFileMask, [0 1; 0 0]))