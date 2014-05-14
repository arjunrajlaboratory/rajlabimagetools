improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();

dirPath = improc2.tests.prepareTempDir();

improc2.utils.saveImageObjectCollectionToDisk(collection, dirPath);

imObjDataFiles = improc2.utils.ImageObjectDataFiles(dirPath);

onDiskCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjDataFiles);

for i = 1:length(collection)
    assert(isequal(collection.getObjectsArray(i), onDiskCollection.getObjectsArray(i)))
end