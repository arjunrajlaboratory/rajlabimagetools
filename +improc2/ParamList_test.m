improc2.tests.cleanupForTests;

x = improc2.ParamList();
improc2.tests.shouldThrowError(@() x.replaceParams(0))
improc2.tests.shouldThrowError(@() x.replaceParams(struct('bogusparam',2)))
