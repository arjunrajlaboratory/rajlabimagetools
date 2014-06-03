dentist.tests.cleanupForTests;

dentistConfig = struct();
dentistConfig.dirPath = dentist.tests.data.locator();
dentistConfig.rows = 2;
dentistConfig.cols = 2;
dentistConfig.layout = struct();
dentistConfig.layout.nextFileDirection = 'down';
dentistConfig.layout.secondaryDirection = 'right';
dentistConfig.layout.snakeOrNoSnake = 'nosnake';
dentistConfig.layout.layoutIndex = 5;
dentistConfig.numPixelOverlap = 103;

dentist.launchingScript;