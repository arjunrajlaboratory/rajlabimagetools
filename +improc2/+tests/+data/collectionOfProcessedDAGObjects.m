function collection = collectionOfProcessedDAGObjects()

    dirPath = improc2.tests.data.locator();
    imObjDataFiles = improc2.utils.ImageObjectDataFiles(dirPath);
    onDiskCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjDataFiles);
    collection = improc2.utils.loadCollectionIntoMemory(onDiskCollection);
    
end
