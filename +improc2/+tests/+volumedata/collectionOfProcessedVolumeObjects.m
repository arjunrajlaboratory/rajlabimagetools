function collection = collectionOfProcessedVolumeObjects()

    dirPath = improc2.tests.volumedata.locator();
    imObjDataFiles = improc2.utils.ImageObjectDataFiles(dirPath);
    onDiskCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjDataFiles);
    collection = improc2.utils.loadCollectionIntoMemory(onDiskCollection);
    improc2.tests.changeImageObjectDirPath(collection, dirPath);
    
end
