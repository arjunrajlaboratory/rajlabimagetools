function launchShiftGUI()
    workingDirectory = pwd;
    dentistConfig = dentist.utils.loadConfig(workingDirectory);
    imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(...
            dentistConfig.dirPath);
    
    inputs = struct();
    inputs.rows = dentistConfig.rows;
    inputs.cols = dentistConfig.cols;
    inputs.nameExt =imageDirectoryReader.imgExts{1};
    inputs.foundChannels = imageDirectoryReader.availableChannels;
    inputs.layoutIndex = dentistConfig.layout.layoutIndex;
    inputs.dirPath = dentistConfig.dirPath;
    
    inputs = dentist.legacy.getFilePaths(inputs);
    dentist.shift.shiftTiles(inputs.filePaths, inputs.foundChannels);
end

