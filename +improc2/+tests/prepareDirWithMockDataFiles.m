function dirPath = prepareDirWithMockDataFiles(cellArrayOfObjectsArrays, fileNumbers)
    
    if nargin < 2
        fileNumbers = 1:length(cellArrayOfObjectsArrays);
    end
    assert(length(fileNumbers) == length(cellArrayOfObjectsArrays), ...
        'fileNums length should match');
    
    baseTempDirPath = tempdir();
    dirPath = [baseTempDirPath filesep 'improc2'];
    if ~isdir(dirPath)
        mkdir(dirPath)
    end
    delete([dirPath, filesep, '*'])
    
    for i = 1:length(cellArrayOfObjectsArrays)
        objects = cellArrayOfObjectsArrays{i};
        fileName = sprintf('%s%sdata%03d.mat', dirPath, filesep, fileNumbers(i));
        save(fileName, 'objects')
    end
