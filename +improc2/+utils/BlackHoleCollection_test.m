improc2.tests.cleanupForTests;

x = improc2.utils.BlackHoleCollection();

anyNumber = 5743;
assert(isempty(x.getObjectsArray(anyNumber)))

anyThing = struct('cat', 5, 'dog', 6);
x.setObjectsArray(anyThing, anyNumber)

% still empty:
assert(isempty(x.getObjectsArray(anyNumber)))