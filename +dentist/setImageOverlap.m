function dentistConfig = setImageOverlap(numPixelOverlap)
    
    workingDirectory = pwd;
    dentistConfig = dentist.utils.loadConfig(workingDirectory);
    
    if nargin < 1
        numPixelOverlap = launchOverlapGUI(dentistConfig);
    end
    dentistConfig.numPixelOverlap = numPixelOverlap;
    
    dentist.utils.saveConfig(dentistConfig, workingDirectory);
    
    
end

function numPixelOverlap = launchOverlapGUI(dentistConfig)
    
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
    
    % launches the GUI
    output = dentist.legacy.getImageOverlap(inputs);
    numPixelOverlap = output.overlap;
    
end

