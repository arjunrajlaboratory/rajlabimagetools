function dirPath = prepareDirWithMockDataFiles(cellArrayOfObjectsArrays, fileNumbers)
    
    if nargin < 2
        fileNumbers = 1:length(cellArrayOfObjectsArrays);
    end
    assert(length(fileNumbers) == length(cellArrayOfObjectsArrays), ...
        'fileNums length should match');
    
    dirPath = improc2.tests.prepareTempDir();
    
    for i = 1:length(cellArrayOfObjectsArrays)
        objects = cellArrayOfObjectsArrays{i};
        fileName = sprintf('%s%sdata%03d.mat', dirPath, filesep, fileNumbers(i));
        save(fileName, 'objects')
    end
