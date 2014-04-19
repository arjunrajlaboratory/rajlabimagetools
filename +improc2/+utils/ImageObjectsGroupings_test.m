improc2.tests.cleanupForTests;

obj1 = struct('annotations', struct('group', improc2.TypeCheckedNumeric(1)));
obj2 = struct('annotations', struct('group', improc2.TypeCheckedNumeric(2)));


obj3 = struct('annotations', struct('group', improc2.TypeCheckedNumeric(3)));


array1 = [obj1, obj2];
array2 = [obj3];

collection = improc2.utils.InMemoryObjectArrayCollection({array1, array2});
objHolder = improc2.utils.ObjectHolder();
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);
annotItemsHandle = improc2.ImageObjectAnnotationsHandle(objHolder);
annotations = improc2.utils.NamedValuesAndChoicesFromItemCollection(annotItemsHandle);

x = improc2.utils.ImageObjectsGroupings(navigator, annotations, 'group');

assert(x.getGroupAssignedTo(1) == 1)
assert(x.getGroupAssignedTo(2) == 2)

x.assignToGroup(1, 30)
assert(x.getGroupAssignedTo(1) == 30)
assert(x.getGroupAssignedTo(2) == 2)
x.assignToGroup(2, 30)
assert(x.getGroupAssignedTo(1) == 30)
assert(x.getGroupAssignedTo(2) == 30)

navigator.tryToGoToObj(1);
assert(annotations.getValue('group') == 30)
navigator.tryToGoToObj(2);
assert(annotations.getValue('group') == 30)

assert(length(x) == 2)

navigator.tryToGoToArray(2)

assert(length(x) == 1)
assert(x.getGroupAssignedTo(1) == 3)
x.assignToGroup(1, 5)
assert(x.getGroupAssignedTo(1) == 5)

navigator.tryToGoToObj(1);
assert(annotations.getValue('group') == 5)
