function dentistData = loadData(dirPath)
   loadedData = load([dirPath, filesep, 'dentistData.mat']);
   dentistData = loadedData.dentistData;
end