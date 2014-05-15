function saveImageObjectCollectionToDisk(collection, dirPath)
    if nargin < 2
        dirPath = pwd;
    end
    
    for i = 1:length(collection)
        dataFileName = sprintf('data%03d.mat', i);
        fileToSave = [dirPath, filesep, dataFileName];
        objects = collection.getObjectsArray(i);
        fprintf(1,'\tSaving data file: %s\n',fileToSave);
        save(fileToSave, 'objects');
    end
    
end