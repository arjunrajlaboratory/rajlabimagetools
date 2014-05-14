function smallCollection = smallCollectionOfProcessedObjects()
    
    collection = improc2.tests.data.collectionOfProcessedDAGObjects();
    
    imObCellArray = {};
    for i = 1:min(2,length(collection))
        objArray = collection.getObjectsArray(i);
        smallObjArray = objArray(1);
        imObCellArray{i} = smallObjArray;
    end
    
    smallCollection = improc2.utils.InMemoryObjectArrayCollection(imObCellArray);
end

