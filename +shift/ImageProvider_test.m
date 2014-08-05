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
provider = shift.ImageProvider(filePaths);

% Test normal movements
assert(all(all(provider.currentImage == 1)),'Current-Initial');
assert(all(all(provider.rightImage == 2)),'Right-Initial');
assert(all(all(provider.downImage == 4)),'Down-Initial');
assert(all(all(provider.downRightImage == 5)),'DownRight-Initial');

provider = provider.moveToNextImageSet();
assert(all(all(provider.currentImage == 2)),'Current-One');
assert(all(all(provider.rightImage == 3)),'Right-One');
assert(all(all(provider.downImage == 5)),'Down-One');
assert(all(all(provider.downRightImage == 6)),'DownRight-One');

provider.moveToNextImageSet();
assert(all(all(provider.currentImage == 4)),'Current-Two');
assert(all(all(provider.rightImage == 5)),'Right-Two');
assert(all(all(provider.downImage == 7)),'Down-Two');
assert(all(all(provider.downRightImage == 8)),'DownRight-Two');

provider.moveToNextImageSet();
provider.moveToNextImageSet();
assert(all(all(provider.currentImage == 1)),'Current-InitialAgain');
assert(all(all(provider.rightImage == 2)),'Right-InitialAgain');
assert(all(all(provider.downImage == 4)),'Down-InitialAgain');
assert(all(all(provider.downRightImage == 5)),'DownRight-InitialAgain');


% Test creating an image
currentUL = [1, 1];
rightUL = [1, 11];
downUL = [11, 1];
downRightUL = [11, 11];
indexToLocMap = containers.Map([1, 2, 3, 4], {currentUL, rightUL,...
    downUL, downRightUL});
order = [1, 2, 3, 4];
canvas = provider.getCanvas(indexToLocMap, order);
assert(all(all(canvas(1:10,1:10) == 1)));
assert(all(all(canvas(1:10,11:20) == 2)));
assert(all(all(canvas(11:20,1:10) == 4)));
assert(all(all(canvas(11:20,11:20) == 5)));

% Test creating an image where order matters - due to overlap
currentUL = [-1, -1];
rightUL = [1, 10];
downUL = [9, 2];
downRightUL = [7, 7];
indexToLocMap = containers.Map([1, 2, 3, 4], {currentUL, rightUL,...
    downUL, downRightUL});
order = [1, 2, 3, 4];
canvasActual = provider.getCanvas(indexToLocMap, order);
canvasExpected = zeros(20,20);
canvasExpected(7:16,7:16) = 5;
canvasExpected(9:18,2:11) = 4;
canvasExpected(1:10,10:19) = 2;
canvasExpected(1:8,1:8) = 1;

assert(all(all(canvasActual == canvasExpected)));

% Moving to random location
provider = provider.moveToRandomImageSet();
assert(isnumeric(provider.currentImage));
assert(isnumeric(provider.rightImage));
assert(isnumeric(provider.downImage));
assert(isnumeric(provider.downRightImage));

rmdir(dirPath,'s');
display('ImageProvider_test - All tests passed!');

