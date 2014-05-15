function collection = collectionOfUnProcessedDAGObjects()

    dirPath = improc2.tests.data.locator();
    imObjDataFiles = improc2.utils.ImageObjectDataFiles(dirPath);
    onDiskCollection = improc2.utils.FileBasedImageObjectArrayCollection(imObjDataFiles);
    
    imObCellArray = {};
    
    for i = 1:length(onDiskCollection)
        savedObjs = onDiskCollection.getObjectsArray(i);
        fileNumberString = sprintf('%03d', i);
        newArray = improc2.dataNodes.GraphBasedImageObject.empty;
        for j = 1:length(savedObjs)
            mask = savedObjs(j).graph.nodes{1}.data.imfilemask;
            newArray(end+1) = ...
                improc2.buildImageObject(mask, fileNumberString, dirPath);
        end
        imObCellArray(end+1) = {newArray};
    end
   
    collection = improc2.utils.InMemoryObjectArrayCollection(imObCellArray);
end

