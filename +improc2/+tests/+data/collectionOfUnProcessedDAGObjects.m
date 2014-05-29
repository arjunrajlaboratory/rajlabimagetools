function collection = collectionOfUnProcessedDAGObjects()
    
    dirPath = improc2.tests.data.locator();
    
    loadedData = load([dirPath, filesep, 'testObjMasks.mat']);
    testObjMasks = loadedData.testObjMasks;
    
    imObCellArray = {};
    for arrayNum = 1:length(testObjMasks)
        imfileMasks = testObjMasks{arrayNum};
        arrayNumberAsString = sprintf('%03d', arrayNum);
        newArray = improc2.dataNodes.GraphBasedImageObject.empty;
        for j = 1:length(imfileMasks)
            obj = improc2.buildImageObject(imfileMasks{j}, arrayNumberAsString, dirPath);
            newArray(end+1) = obj;
        end
        imObCellArray{arrayNum} = newArray;
    end
    collection = improc2.utils.InMemoryObjectArrayCollection(imObCellArray);
    
end

