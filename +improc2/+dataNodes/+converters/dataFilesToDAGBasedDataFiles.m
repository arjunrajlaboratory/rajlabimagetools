function dataFilesToDAGBasedDataFiles(dirPath)
    
    if nargin < 1
        dirPath = pwd;
    end
    imObjFiles = improc2.utils.ImageObjectDataFiles(dirPath);
    
    backupFiles = imObjFiles;
    backupFiles.dataFileNames = cellfun(@(x) ['BACKUP_', x], backupFiles.dataFileNames, ...
        'UniformOutput', false);
    
    originalCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjFiles);
    destinationCollection = originalCollection;
    backupCollection = improc2.utils.FileBasedImageObjectArrayCollection(backupFiles);
    
    improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
        originalCollection, destinationCollection, backupCollection);
end

