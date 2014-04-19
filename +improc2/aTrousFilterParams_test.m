improc2.tests.cleanupForTests;

x = improc2.aTrousFilterParams;
x = x.replaceParams(struct('sigma', 1, 'numLevels', 3));
assert(x.sigma == 1 && x.numLevels == 3)
x = x.replaceParams(struct('numLevels', 5));
assert(x.sigma == 1 && x.numLevels == 5)
improc2.tests.shouldThrowError(@() x.replaceParams(struct('nlevels',3)))
