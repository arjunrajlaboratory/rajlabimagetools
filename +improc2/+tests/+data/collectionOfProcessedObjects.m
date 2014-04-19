function collection = collectionOfProcessedObjects()
    
    dirPath = improc2.tests.data.locator();
    
    objHolder = improc2.utils.ObjectHolder();
    procRegistrar = improc2.ProcessorRegistrar(objHolder);
    
    load([dirPath, 'dataToReconstructObjects.mat'])
    
    imObCellArray = {};
    
    for i =1:length(data)
        currentData = data{i};
        
        imFileMask = currentData.mask;
        imagenumber = sprintf('%03d',currentData.arrayNum);
        imOb = improc2.ImageObject(imFileMask, imagenumber, dirPath);
        objHolder.obj = imOb;
        for channelName = procRegistrar.channelNames;
            preProcessedData = currentData.procData.(char(channelName));
            procRegistrar.registerNewProcessor(preProcessedData, channelName);
        end
        imOb = objHolder.obj;
        
        arrayNum = currentData.arrayNum;
        if length(imObCellArray) < arrayNum
            imObCellArray = [imObCellArray, {imOb}];
        else
            imObCellArray{arrayNum} = [imObCellArray{arrayNum}, imOb];
        end
    end
    
    collection = improc2.utils.InMemoryObjectArrayCollection(imObCellArray);
end