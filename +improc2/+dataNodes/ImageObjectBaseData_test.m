improc2.tests.cleanupForTests;


x = improc2.dataNodes.ImageObjectBaseData();
assert(isempty(x.imfilemask))

imfilemask = [0 1 1 1 1; 0 1 1 1 0; 0 0 0 0 0];
x.imfilemask = imfilemask;

assert(isequal(x.imfilemask, imfilemask))
assert(isequal(x.boundingbox, [2 1 3 1]))

expectedCroppedMask = [1 1 1 1; 1 1 1 0];
assert(isequal(x.mask, expectedCroppedMask))