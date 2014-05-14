improc2.tests.cleanupForTests;
collection = improc2.tests.data.collectionOfProcessedObjects();

x = improc2.thresholdGUI.launchThresholdGUICore(collection);


graphCollection = improc2.utils.InMemoryObjectArrayCollection(...
    cell(1,length(collection)));
improc2.dataNodes.converters.convertCollectionFromStackBasedToDAGBased(...
    collection, graphCollection);

x2 = improc2.thresholdGUI.launchThresholdGUICore(graphCollection);