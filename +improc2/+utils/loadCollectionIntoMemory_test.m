improc2.tests.cleanupForTests;

cellArray = {[10 11], 20};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);

% could use any collection, including a file based one.

x = improc2.utils.loadCollectionIntoMemory(collection);
assert(isa(x, 'improc2.utils.InMemoryObjectArrayCollection'));

% showing that x is a new collection, independent from the old:
collection.setObjectsArray(30, 2)

assert(collection.getObjectsArray(2) == 30)

assert(x.getObjectsArray(2) == 20)
