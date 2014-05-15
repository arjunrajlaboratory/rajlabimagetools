improc2.tests.cleanupForTests;

inMemoryCollection = improc2.tests.data.collectionOfProcessedDAGObjects();

tools = improc2.launchImageObjectTools(inMemoryCollection);

x = improc2.AnnotationsAdder(tools.annotationItemAdder, ...
    tools.annotations, tools.iterator);

assert(ismember('isGood', tools.annotations.itemNames))

x.specifyNewFactorItem('cellType', {'hela', 'crl', 'hkaryon'})
x.specifyNewYesNoOrNAItem('isMitotic')
x.specifyNewNumericItem('numNeighbors')
x.specifyNewStringItem('notes')

% error if use existing name or an already specified new item name
improc2.tests.shouldThrowError(@() x.specifyNewStringItem('isGood'), ...
    'improc2:ItemWithNameExists')

improc2.tests.shouldThrowError(@() x.specifyNewStringItem('cellType'), ...
    'improc2:ItemWithNameExists')

x.addNewItemsToAllObjectsAndQuit()

tools.refresh();

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration
    assert(isequal(tools.annotations.getValue('cellType'), 'NA'))
    assert(isequal(tools.annotations.getValue('isMitotic'), 'NA'))
    assert(isnan(tools.annotations.getValue('numNeighbors')))
    assert(isempty(tools.annotations.getValue('notes')))
    tools.iterator.goToNextObject()
end
