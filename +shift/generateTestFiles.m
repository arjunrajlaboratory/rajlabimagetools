dirPath = 'testing_directory';
if isdir(dirPath)
    rmdir(dirPath,'s');
end
mkdir(dirPath);

filePaths = cell(3,3,2);
for r = 1:3
    for c = 1:3
        index = ((r-1) * 3) + c;
        
        dapi = zeros(10,10,3);
        dapi(:) = index/9 *255;
        dapiName = ['dapi00',num2str(index),'.jpg'];
        dapiPath = [dirPath, filesep, dapiName];
        imwrite(dapi, dapiPath);
        
        tmr = zeros(10,10,3);
        tmr(:,:,1) = (rand() * 255)/255;
        tmr(:,:,2) = (rand() * 255)/255;
        tmr(:,:,3) = (rand() * 255)/255;
        tmrName = ['tmr00',num2str(index),'.jpg'];
        tmrPath = [dirPath, filesep, tmrName];
        imwrite(tmr, tmrPath);
        
        filePaths{r,c,1} = tmrPath;
        filePaths{r,c,2} = dapiPath;
    end
end