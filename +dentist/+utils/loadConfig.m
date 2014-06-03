function dentistConfig = loadConfig(dirPath)
   loadedData = load([dirPath, filesep, 'dentistConfig.mat']);
   dentistConfig = loadedData.dentistConfig;
end