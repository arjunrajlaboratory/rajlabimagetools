improc2.tests.cleanupForTests;


testGUIObjectMaker = @improc2.tests.ObjectMaskDisplayerFromObjHolder;

extraParams = struct('collection', improc2.tests.data.collectionOfProcessedObjects());

improc2.launchQuickGUI(testGUIObjectMaker, extraParams);
