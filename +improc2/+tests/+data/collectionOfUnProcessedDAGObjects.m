function collection = collectionOfUnProcessedDAGObjects()

    collection = improc2.tests.data.collectionOfUnProcessedObjects();
    
    improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
        collection, collection)
end

