function saveConfig(dentistConfig, dirPath)
   filename = [dirPath, filesep, 'dentistConfig.mat'];
   save(filename, 'dentistConfig');
end