improc2.tests.cleanupForTests;

collection = improc2.utils.InMemoryObjectArrayCollection({[10, 11]});
objHolder = improc2.utils.ObjectHolder();
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);

assert(objHolder.obj == 10)
x.tryToGoToNextObj();
assert(objHolder.obj == 11)
x.tryToGoToNextObj();
assert(objHolder.obj == 11)
x.tryToGoToPrevObj();
assert(objHolder.obj == 10)
x.tryToGoToPrevObj();
assert(objHolder.obj == 10)

assert(x.numberOfArrays == 1)
assert(x.numberOfObjectsInCurrentArray == 2)

%% fail if no image objects.

collection = improc2.utils.InMemoryObjectArrayCollection({[]});
improc2.tests.shouldThrowError(...
    @() improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder), ...
    'improc2:NoImageObjects');


%% navigating when there are empty objectArrays

collection = improc2.utils.InMemoryObjectArrayCollection(...
    {[], [], [10 11], [], [], [20 21], []});
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);

assert(x.numberOfArrays == length(collection))

assert(objHolder.obj == 10)
assert(x.currentObjNum == 1)
assert(x.currentArrayNum == 3)
x.tryToGoToPrevObj()
assert(objHolder.obj == 10)
assert(x.currentObjNum == 1)
assert(x.currentArrayNum == 3)
x.tryToGoToNextObj()
assert(objHolder.obj == 11)
assert(x.currentObjNum == 2)
assert(x.currentArrayNum == 3)
x.tryToGoToNextObj()
assert(objHolder.obj == 20)
assert(x.currentObjNum == 1)
assert(x.currentArrayNum == 6)
x.tryToGoToNextObj()
assert(objHolder.obj == 21)
x.tryToGoToNextObj()
assert(objHolder.obj == 21)

x.tryToGoToArray(3)
assert(objHolder.obj == 10)
x.tryToGoToArray(6)
assert(objHolder.obj == 20)
x.tryToGoToArray(2)
assert(objHolder.obj == 10)
x.tryToGoToArray(0)
assert(objHolder.obj == 10)
x.tryToGoToArray(4)
assert(objHolder.obj == 20)
x.tryToGoToArray(7)
assert(objHolder.obj == 20)
x.tryToGoToArray(10)
assert(objHolder.obj == 20)
improc2.tests.shouldThrowError(@() x.tryToGoToArray(1.5), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.tryToGoToArray([1 2]), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.tryToGoToArray('a'), 'improc2:BadArguments')

x.tryToGoToArray(6)
assert(objHolder.obj == 20)
x.tryToGoToObj(2)
assert(objHolder.obj == 21)
x.tryToGoToObj(3)
assert(objHolder.obj == 21)
improc2.tests.shouldThrowError(@() x.tryToGoToObj(0), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.tryToGoToObj([1 2]), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.tryToGoToObj(1.5), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.tryToGoToObj('a'), 'improc2:BadArguments')

% saving behavior: saves when you try to switch between arrays.

originalObj1 = 1;
originalObj2 = 2;
originalObj3 = 3;
modifiedObj1 = 11;
modifiedObj2 = 21;
modifiedObj3 = 23;

cellArray = {originalObj1};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder); 
assert(collection.getObjectsArray(1) == originalObj1)
objHolder.obj = modifiedObj1;
assert(objHolder.obj == modifiedObj1);
assert(collection.getObjectsArray(1) == originalObj1)
x.tryToGoToNextObj();
assert(collection.getObjectsArray(1) == modifiedObj1)

cellArray = {originalObj1};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder); 
objHolder.obj = modifiedObj1;
x.tryToGoToPrevObj();
assert(collection.getObjectsArray(1) == modifiedObj1)

cellArray = {originalObj1};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder); 
objHolder.obj = modifiedObj1;
x.tryToGoToArray(1);
assert(collection.getObjectsArray(1) == modifiedObj1)

% discard unsaved changes and reload

cellArray = {originalObj1};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder); 
objHolder.obj = modifiedObj1;
x.discardUnsavedChangesAndReload();
objHolder.obj = originalObj1;
assert(collection.getObjectsArray(1) == originalObj1)

% calling update methods on dependents: usually necessary for objects that
% drive GUIs.

mockUpdateable = improc2.tests.MockUpdateable();

x.addActionAfterMoveAttempt(mockUpdateable, @update);

assert(mockUpdateable.numUpdates == 0)
x.tryToGoToNextObj();
assert(mockUpdateable.numUpdates == 1)
x.tryToGoToPrevObj();
assert(mockUpdateable.numUpdates == 2)
x.tryToGoToArray(1);
assert(mockUpdateable.numUpdates == 3)
x.tryToGoToObj(1);
assert(mockUpdateable.numUpdates == 4)
x.discardUnsavedChangesAndReload();
assert(mockUpdateable.numUpdates == 5)


% Bug I had where tryToGoToArray would cause overwriting the wrong array in
% the collection.

collection = improc2.utils.InMemoryObjectArrayCollection(...
    {[], [], [10 11], [], [], [20 21], []});
x = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);
assert(isempty(collection.getObjectsArray(1)))
x.tryToGoToArray(1)
assert(isempty(collection.getObjectsArray(1)))

