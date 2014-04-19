improc2.tests.cleanupForTests;

mockItemCollectionHandle = struct();
mockItemCollectionHandle.itemNames = {'isGood', 'cellType'};
mockItemCollectionHandle.itemClasses = {'someClass', 'someOtherClass'};

improc2.utils.printItemCollectionSignature(mockItemCollectionHandle);
fprintf('Should have printed isGood and cellType in one column and classnames in another\n')
