improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();

annotsToAdd = struct();
annotsToAdd.morphology = {'smooth', 'rough'};
annotsToAdd.notes = '';
annotsToAdd.numNeighbors = 0;
improc2.addAnnotationItemsToAllObjects(annotsToAdd, collection);

x = improc2.launchThresholdGUI(collection);
