dentist.tests.cleanupForTests;

testDataDir = dentist.tests.data.locator();
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(testDataDir);

dentistConfig = struct();
dentistConfig.rows = 2;
dentistConfig.cols = 2;

inputs = struct();

inputs.rows = dentistConfig.rows;
inputs.cols = dentistConfig.cols;

inputs.nameExt =imageDirectoryReader.imgExts{1};
inputs.foundChannels = imageDirectoryReader.availableChannels;
inputs.dirPath = imageDirectoryReader.dirPath;

output = dentist.getLayoutOrientation(inputs);


layout = struct();

[layout.nextFileDirection, ...
    layout.secondaryDirection, ...
    layout.snakeOrNoSnake] = ... 
    dentist.utils.interpretLayoutTypeNumber(output.layoutIndex);

dentistConfig.layout = layout;

% imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');