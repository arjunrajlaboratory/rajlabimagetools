improc2.tests.cleanupForTests;

x = improc2.RemembersRunAndDataChange();
assert(~x.isProcessed)
x = x.run();
assert(x.isProcessed)
