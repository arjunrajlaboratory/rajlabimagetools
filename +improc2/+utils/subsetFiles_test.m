improc2.tests.cleanupForTests;

dataFiles = {'dog', 'cat', 'rabbit', 'mouse'};
dataNums = [2, 3, 4, 5];

[outFiles, outNums] = improc2.utils.subsetFiles(dataFiles, dataNums, []);

assert(isequal(outFiles, dataFiles))
assert(isequal(outNums, dataNums))

[outFiles, outNums] = improc2.utils.subsetFiles(dataFiles, dataNums, [4, 3]);

% no guarantee about what order these guys will come out in.
[sortedOutNums, ordering] = sort(outNums, 'ascend');
sortedOutFiles = outFiles(ordering);

assert(all(sortedOutNums == [3, 4]))
assert(all(strcmp(sortedOutFiles, dataFiles(2:3))))

improc2.tests.shouldThrowError( ...
    @() improc2.utils.subsetFiles(dataFiles, dataNums, [4, 5, 6]), ...
    'improc2:SomeToSelectNotFound')

improc2.tests.shouldThrowError( ...
    @() improc2.utils.subsetFiles(dataFiles, dataNums, [1]), ...
    'improc2:SomeToSelectNotFound')
