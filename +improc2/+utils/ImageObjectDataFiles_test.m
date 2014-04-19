improc2.tests.cleanupForTests;

dirPath = improc2.tests.prepareDirWithMockDataFiles(cell(5,1),[1,2,3,5,8]);

x = improc2.utils.ImageObjectDataFiles(dirPath);

expectedDataFiles = {'data001.mat', 'data002.mat', ...
    'data003.mat', 'data005.mat', 'data008.mat'};
assert(all(strcmp(x.dataFileNames, expectedDataFiles)))
assert(all(x.dataNums == [1, 2, 3, 5, 8]))
filesInDir = dir(x.dirPath);
assert(all(ismember(expectedDataFiles, {filesInDir.name})))

x = improc2.utils.ImageObjectDataFiles(dirPath, [3 8]);

expectedDataFiles = {'data003.mat', 'data008.mat'};
assert(all(strcmp(x.dataFileNames, expectedDataFiles)))
assert(all(x.dataNums == [3, 8]))
filesInDir = dir(x.dirPath);
assert(all(ismember(expectedDataFiles, {filesInDir.name})))

improc2.tests.shouldThrowError(...
    @() improc2.utils.ImageObjectDataFiles(dirPath, [4 8]), 'improc2:SomeToSelectNotFound')

emptyDir = improc2.tests.prepareDirWithMockDataFiles({});
y = improc2.utils.ImageObjectDataFiles(emptyDir);
assert(isempty(y.dataFileNames))
assert(isempty(y.dataNums))


