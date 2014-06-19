dentist.tests.cleanupForTests;

dentistConfig = struct();
dentistConfig.dirPath = dentist.tests.data.locator();
dentistConfig.rows = 2;
dentistConfig.cols = 2;
dentistConfig.maxDistance = 200;
dentistConfig.layout = struct();
dentistConfig.layout.nextFileDirection = 'down';
dentistConfig.layout.secondaryDirection = 'right';
dentistConfig.layout.snakeOrNoSnake = 'nosnake';
dentistConfig.layout.layoutIndex = 5;
dentistConfig.numPixelOverlap = 103;


saveDataToDisk = false;
dentistData = dentist.processImages(dentistConfig, saveDataToDisk);

controls = dentist.launchGUI(dentistConfig, dentistData);