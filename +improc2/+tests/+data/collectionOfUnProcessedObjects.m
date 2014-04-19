function collection = collectionOfUnProcessedObjects()
    
    dirPath = improc2.tests.data.locator();
    
    load([dirPath, 'dataToReconstructObjects.mat'])
    
    imObCellArray = {};
    
    for i =1:length(data)
        currentData = data{i};
        
        imFileMask = currentData.mask;
        imagenumber = sprintf('%03d',currentData.arrayNum);
        imOb = improc2.ImageObject(imFileMask, imagenumber, dirPath);        
        arrayNum = currentData.arrayNum;
        if length(imObCellArray) < arrayNum
            imObCellArray = [imObCellArray, {imOb}];
        else
            imObCellArray{arrayNum} = [imObCellArray{arrayNum}, imOb];
        end
    end
    
    collection = improc2.utils.InMemoryObjectArrayCollection(imObCellArray);
end

