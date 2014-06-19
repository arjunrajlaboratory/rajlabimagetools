function saveData(dentistData, dirPath)
   filename = [dirPath, filesep, 'dentistData.mat'];
   save(filename, 'dentistData');
end