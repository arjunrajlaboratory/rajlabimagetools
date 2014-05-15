improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

annotationsAdder = improc2.launchAnnotationsAdder(inMemoryCollection);
annotationsAdder.specifyNewNumericItem('testGroup');
annotationsAdder.addNewItemsToAllObjectsAndQuit();

x = improc2.launchObjectGroupingGUI('testGroup', inMemoryCollection);
