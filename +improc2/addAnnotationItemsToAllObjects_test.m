improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedObjects();

browser = improc2.launchImageObjectBrowsingTools(inMemoryCollection);

assert(isequal(browser.annotations.itemNames, {'isGood'}))

annotsToAdd = struct();
annotsToAdd.cellType = {'hela', 'crl'};
annotsToAdd.isMitotic = false;
improc2.addAnnotationItemsToAllObjects(annotsToAdd, inMemoryCollection)

browser.refresh();
assert(all(strcmp(browser.annotations.itemNames, {'isGood', 'cellType', 'isMitotic'}')))
