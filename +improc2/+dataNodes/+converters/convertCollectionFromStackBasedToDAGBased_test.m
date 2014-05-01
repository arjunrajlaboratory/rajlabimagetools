improc2.tests.cleanupForTests;

stackBasedCollection = improc2.tests.data.collectionOfProcessedObjects();

destinationCollection = improc2.utils.InMemoryObjectArrayCollection(...
    cell(1,length(stackBasedCollection)));

backupCollection = improc2.utils.InMemoryObjectArrayCollection(...
    cell(1,length(stackBasedCollection)));

% improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
%     stackBasedCollection, destinationCollection, backupCollection);

