improc2.tests.cleanupForTests;

initialGroupings = [1 3 NaN 3 NaN];
mockGroupableItems = improc2.tests.MockGroupableItems(initialGroupings);

x = improc2.utils.Grouper(mockGroupableItems);
x.assignGroupsToItemsAssignedToNaN()

expectedGroupings = [1 3 2 3 4];
for i = 1:length(mockGroupableItems)
    assert(mockGroupableItems.getGroupAssignedTo(i) == expectedGroupings(i))
end

x.assignItemsToAGroup([2, 3, 4])
expectedGroupings = [1 2 2 2 4];
for i = 1:length(mockGroupableItems)
    assert(mockGroupableItems.getGroupAssignedTo(i) == expectedGroupings(i))
end

%% tests of grouping

initialGroupings = [1 1 2 2 3 3];
mockGroupableItems = improc2.tests.MockGroupableItems(initialGroupings);
x = improc2.utils.Grouper(mockGroupableItems);

x.assignItemsToAGroup([2, 4, 5])
expectedGroupings = [1 4 2 4 4 3];
for i = 1:length(mockGroupableItems)
    assert(mockGroupableItems.getGroupAssignedTo(i) == expectedGroupings(i))
end

x.assignItemsToAGroup([2, 4, 5])
expectedGroupings = [1 4 2 4 4 3];
for i = 1:length(mockGroupableItems)
    assert(mockGroupableItems.getGroupAssignedTo(i) == expectedGroupings(i))
end

x.assignItemsToAGroup([4])
expectedGroupings = [1 4 2 5 4 3];
for i = 1:length(mockGroupableItems)
    assert(mockGroupableItems.getGroupAssignedTo(i) == expectedGroupings(i))
end

