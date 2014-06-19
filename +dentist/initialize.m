function dentistConfig = initialize(Nrows, Ncols, pathToRawImages)
    if nargin < 2
        error('must specify rows and columns as first input')
    end
    if nargin < 3
        pathToRawImages = '.';
    end
    
    dentistConfig = struct();
    % check if ther are actually raw images in this directory:
    directoryReader = dentist.utils.ImageFileDirectoryReader(pathToRawImages);
    dentistConfig.dirPath = directoryReader.dirPath;
    
    dentistConfig.rows = Nrows;
    dentistConfig.cols = Ncols;
    
    dentistConfig.maxDistance = 200;
    
    workingDirectory = pwd;
    dentist.utils.saveConfig(dentistConfig, workingDirectory);
end

