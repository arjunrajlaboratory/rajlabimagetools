improc2.tests.cleanupForTests;

x = improc2.utils.DependencyRunner();

a = improc2.tests.MockUpdateable();
b = improc2.tests.MockUpdateable();

x.registerDependency(a, @update)
x.registerDependency(b, @update)

assert(a.numUpdates == 0)
assert(b.numUpdates == 0)
x.runDependencies()
assert(a.numUpdates == 1)
assert(b.numUpdates == 1)

delete(a)
x.runDependencies()
assert(b.numUpdates == 2)
