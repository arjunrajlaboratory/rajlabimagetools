improc2.tests.cleanupForTests;

objHolder = improc2.utils.ObjectHolder();
collection = improc2.utils.InMemoryObjectArrayCollection(...
    {[], [], [10 11], [], [], [20 21 23], []});
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);

x = improc2.ImageObjectIterator(navigator);

objectsFound = [];

x.goToFirstObject()
while x.continueIteration
    objectsFound = [objectsFound objHolder.obj];
    x.goToNextObject()
end

assert(all(objectsFound == [10 11 20 21 23]))
    

collection = improc2.utils.InMemoryObjectArrayCollection({[18]});
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);

x = improc2.ImageObjectIterator(navigator);

objectsFound = [];

x.goToFirstObject()
while x.continueIteration
    objectsFound = [objectsFound objHolder.obj];
    x.goToNextObject()
end

assert(all(objectsFound == [18]))
