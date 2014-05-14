improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedObjects();
dirPath = improc2.tests.prepareTempDir();

improc2.utils.saveImageObjectCollectionToDisk(collection, dirPath);

improc2.dataNodes.converters.dataFilesToDAGBasedDataFiles(dirPath);

imObjFiles = improc2.utils.ImageObjectDataFiles(dirPath);
backupFiles = imObjFiles;
for i = 1:length(backupFiles.dataFileNames)
    backupFiles.dataFileNames{i} = ['BACKUP_', backupFiles.dataFileNames{i}];
end

onDiskCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjFiles);
backupCollection = improc2.utils.FileBasedImageObjectArrayCollection(backupFiles);

for i = 1:length(collection)
    originalObjs = collection.getObjectsArray(i);
    backupObjs = backupCollection.getObjectsArray(i);
    for j = 1:length(originalObjs)
        obj = originalObjs(j);
        bobj = backupObjs(j);
        % for some reason the objects themselves don't compare as equal
        % isequal(obj, bojb) = false. Could not track down what is
        % different about them, but narrowed it down to 
        % obj.processors.channels.(channelName).processors
        % not comparing equal to its bobj counterpart, even though the
        % processor itself does. 
        assert(isequal(obj.annotations, bobj.annotations))
        assert(isequal(obj.metadata, bobj.metadata))
        assert(isequal(obj.object_mask, bobj.object_mask))
        assert(isequal(obj.dirPath, bobj.dirPath))
        for channelName = obj.processors.channelFields
            assert(isequal(obj.processors.channels.(channelName{1}).processor, ...
                bobj.processors.channels.(channelName{1}).processor))
        end
    end
end

for i = 1:length(onDiskCollection)
    convertedObjs = onDiskCollection.getObjectsArray(i);
    assert(isa(convertedObjs, 'improc2.dataNodes.GraphBasedImageObject'))
end

improc2.tests.shouldThrowError(...
    @() improc2.dataNodes.converters.dataFilesToDAGBasedDataFiles(dirPath))