function inMemoryCollection = loadCollectionIntoMemory(arrayCollection)
    
    cellArray = cell(1, length(arrayCollection));
    for i = 1:length(arrayCollection)
        cellArray{i} = arrayCollection.getObjectsArray(i);
    end
    inMemoryCollection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
end

