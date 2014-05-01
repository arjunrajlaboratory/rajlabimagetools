improc2.tests.cleanupForTests;

stackBasedCollection = improc2.tests.data.collectionOfProcessedObjects();

destinationCollection = improc2.utils.InMemoryObjectArrayCollection(...
    cell(1,length(stackBasedCollection)));

backupCollection = improc2.utils.InMemoryObjectArrayCollection(...
    cell(1,length(stackBasedCollection)));

improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
    stackBasedCollection, destinationCollection, backupCollection);

for i = 1:length(stackBasedCollection)
    assert(isequal(stackBasedCollection.getObjectsArray(i), ...
        backupCollection.getObjectsArray(i)))
    oldArray = stackBasedCollection.getObjectsArray(i);
    newArray = destinationCollection.getObjectsArray(i);
    assert(length(newArray) == length(oldArray))
    assert(isa(newArray, 'improc2.dataNodes.GraphBasedImageObject'))
end