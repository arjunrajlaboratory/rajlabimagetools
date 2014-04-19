clear; clear classes;
dirPath = 'doesNotExist';
nameExt = '.bogusExt';
foundChannels = {'dapi','cy','alexa','tmr'};
Nrows = 3;
Ncols = 3;
layoutIndex = 5;
fp = dentist.utils.buildFilePathsGrid(dirPath, nameExt, foundChannels, ...
    Nrows, Ncols, 'down', 'right', 'nosnake');
assert(strcmp(fp{1,1,1}, ['doesNotExist' filesep 'dapi001.bogusExt']))
assert(strcmp(fp{3,1,1}, ['doesNotExist' filesep 'dapi003.bogusExt']))
assert(strcmp(fp{3,2,1}, ['doesNotExist' filesep 'dapi006.bogusExt']))
assert(strcmp(fp{3,2,2}, ['doesNotExist' filesep 'cy006.bogusExt']))
assert(strcmp(fp{3,2,3}, ['doesNotExist' filesep 'alexa006.bogusExt']))
assert(strcmp(fp{3,2,4}, ['doesNotExist' filesep 'tmr006.bogusExt']))

