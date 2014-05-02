function collection = collectionOfProcessedDAGObjects()

    collection = improc2.tests.data.collectionOfProcessedObjects();
    
    improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
        collection, collection)
end
