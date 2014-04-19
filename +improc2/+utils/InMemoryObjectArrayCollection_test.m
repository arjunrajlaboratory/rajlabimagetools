improc2.tests.cleanupForTests;

cellArray = {[], [1 3], 4};
x = improc2.utils.InMemoryObjectArrayCollection(cellArray);

assert(length(x) == 3)
assert(isempty(x.getObjectsArray(1)))
assert(x.getObjectsArray(3) == 4)
assert(all(x.getObjectsArray(2) == [1 3]))

x.setObjectsArray(15, 3)
assert(x.getObjectsArray(3) == 15)
x.setObjectsArray([10 30], 2)
assert(all(x.getObjectsArray(2) == [10 30]))
