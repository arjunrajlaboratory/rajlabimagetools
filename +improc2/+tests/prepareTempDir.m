function dirPath = prepareTempDir()
    baseTempDirPath = tempdir();
    dirPath = [baseTempDirPath filesep 'improc2'];
    if ~isdir(dirPath)
        mkdir(dirPath)
    end
    delete([dirPath, filesep, '*'])
end

