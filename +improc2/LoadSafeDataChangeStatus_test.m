improc2.tests.cleanupForTests;

baseTempDirPath = tempdir();
dirPath = [baseTempDirPath filesep 'improc2'];
if ~isdir(dirPath)
    mkdir(dirPath)
end
delete([dirPath, filesep, '*'])

x = improc2.tests.MinimalLoadSafeDataChangeStatus;
x = x.setNotChanged();
assert(~x.dataHasChanged)
x.value = 3;
assert(x.value == 3)
assert(x.dataHasChanged)
x = x.setNotChanged();
assert(~x.dataHasChanged)
save([dirPath, filesep, 'x.mat'],'x')
load([dirPath, filesep, 'x.mat'])
assert(~x.dataHasChanged)
