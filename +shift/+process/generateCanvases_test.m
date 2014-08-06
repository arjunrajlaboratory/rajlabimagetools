dirPath = 'testing_directory';
if isdir(dirPath)
    rmdir(dirPath,'s');
end
mkdir(dirPath);

filePaths = cell(3,3,2);
for r = 1:3
    for c = 1:3
        index = ((r-1) * 3) + c;
        
        dapi = zeros(10,10);
        dapi(:) = index/255;
        dapiName = ['dapi00',num2str(index),'.tiff'];
        dapiPath = [dirPath, filesep, dapiName];
        imwrite(dapi, dapiPath);
        
        tmr = zeros(10,10);
        tmr(:) = index/255;
        tmrName = ['tmr00',num2str(index),'.tiff'];
        tmrPath = [dirPath, filesep, tmrName];
        imwrite(tmr, tmrPath);
        
        filePaths{r,c,1} = tmrPath;
        filePaths{r,c,2} = dapiPath;
    end
end
% Test 1
imageSize = [10, 10];
tileSize = [5, 5];
gridR = [1, 1, 1;...
        11, 11, 11;...
        21, 21, 21];
    
gridC = [1, 11, 21;...
        1, 11, 21;...
        1, 11, 21];
grid = cat(3, gridR,gridC);
r = 10;
c = 10;
canvases = shift.process.generateCanvases(r, c, filePaths, imageSize,...
        tileSize, grid);
canvas = canvases{1};
canvasExpected = [0 0 0 0 0; 0 5 5 5 5; 0 5 5 5 5; 0 5 5 5 5; 0 5 5 5 5];
assert(all(all(canvas == canvasExpected)))
% Test 2
imageSize = [10, 10];
tileSize = [15, 15];
gridR = [1, 1, 1;...
        11, 11, 11;...
        21, 21, 21];
    
gridC = [1, 11, 21;...
        1, 11, 21;...
        1, 11, 21];
grid = cat(3, gridR,gridC);
r = 11;
c = 11;
canvases = shift.process.generateCanvases(r, c, filePaths, imageSize,...
        tileSize, grid);
canvas = canvases{1};
canvasExpected = zeros(15,15);
canvasExpected(1:10,1:10) = 5;
canvasExpected(11:15,1:10) = 8;
canvasExpected(1:10,11:15) = 6;
canvasExpected(11:15,11:15) = 9;
assert(all(all(canvas == canvasExpected)));









rmdir(dirPath,'s');