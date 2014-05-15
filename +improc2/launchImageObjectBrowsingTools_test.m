improc2.tests.cleanupForTests;
inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

x = improc2.launchImageObjectBrowsingTools(inMemoryCollection);

originalVal = x.annotations.getValue('isGood');
modifiedVal = ~originalVal;
x.annotations.setValue('isGood', modifiedVal);
assert(x.annotations.getValue('isGood') == modifiedVal)
x.refresh();
assert(x.annotations.getValue('isGood') == originalVal)
