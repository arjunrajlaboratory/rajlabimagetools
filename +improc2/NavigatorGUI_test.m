improc2.tests.cleanupForTests;

objHolder = improc2.tests.MockObjHolder();
collection = improc2.utils.InMemoryObjectArrayCollection(...
    {[], [], [10 11], [], [], [20 21], []});
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);

x = improc2.NavigatorGUI(navigator);

