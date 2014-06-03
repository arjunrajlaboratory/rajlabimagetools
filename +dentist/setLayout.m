function dentistConfig = setLayout(layout)
    
    workingDirectory = pwd;
    
    dentistConfig = dentist.utils.loadConfig(workingDirectory);
    
    if nargin < 1
        layout = launchLayoutSelectorGUI(dentistConfig);
    end
    
    dentistConfig.layout = struct();
    dentistConfig.layout.nextFileDirection = layout.nextFileDirection;
    dentistConfig.layout.secondaryDirection = layout.secondaryDirection;
    dentistConfig.layout.snakeOrNoSnake = layout.snakeOrNoSnake;
    dentistConfig.layout.layoutIndex = layout.layoutIndex;
    
    dentist.utils.saveConfig(dentistConfig, workingDirectory);
end

function layout = launchLayoutSelectorGUI(dentistConfig)
    
    imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(...
        dentistConfig.dirPath);
    
    inputs = struct();
    
    inputs.rows = dentistConfig.rows;
    inputs.cols = dentistConfig.cols;
    inputs.nameExt =imageDirectoryReader.imgExts{1};
    inputs.foundChannels = imageDirectoryReader.availableChannels;
    inputs.dirPath = imageDirectoryReader.dirPath;
    
    % Launches the GUI
    output = dentist.legacy.getLayoutOrientation(inputs);
    
    layout = struct();
    layout.layoutIndex = output.layoutIndex;
    [layout.nextFileDirection, ...
        layout.secondaryDirection, ...
        layout.snakeOrNoSnake] = ...
        dentist.utils.interpretLayoutTypeNumber(layout.layoutIndex);
    
end