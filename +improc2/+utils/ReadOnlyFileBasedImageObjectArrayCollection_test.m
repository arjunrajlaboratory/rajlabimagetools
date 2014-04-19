improc2.tests.cleanupForTests;

dirPath = improc2.tests.prepareDirWithMockDataFiles({'fake1', 'fake2'});
imageObjectDataFiles = improc2.utils.ImageObjectDataFiles(dirPath);
x = improc2.utils.ReadOnlyFileBasedImageObjectArrayCollection(imageObjectDataFiles);

assert(length(x) == 2)
assert(strcmp(x.getObjectsArray(1), 'fake1'))
assert(strcmp(x.getObjectsArray(2), 'fake2'))

x.setObjectsArray('modified1', 1)
unmodifiedValue = 'fake1';

assert(strcmp(x.getObjectsArray(1), 'fake1'))
loadedVariables = load([imageObjectDataFiles.dirPath, filesep, ...
    imageObjectDataFiles.dataFileNames{1}]);
assert(strcmp(loadedVariables.objects, unmodifiedValue))


