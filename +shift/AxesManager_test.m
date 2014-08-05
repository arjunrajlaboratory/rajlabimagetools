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

keyInterpreter = shift.AxesManager_KeyPressInterpreter_stub();

axesManager = shift.AxesManager(provider, keyInterpreter);

% =========== TEST SELECTION ==========
keyInterpreter.controlDown = false;
axesManager.registerClick([15, 15]);
assert(axesManager.selected == 4,'a');

axesManager.registerClick([5, 25]);
assert(axesManager.selected == 4,'Out of bounds');

axesManager.registerClick([5, 5]);
assert(axesManager.selected == 1,'a');

keyInterpreter.controlDown = true;
axesManager.registerClick([15, 5]);
assert(all(axesManager.selected == [1, 3]), 'b')

axesManager.registerClick([5, 15]);
assert(all(axesManager.selected == [1, 3, 2]),'c');

display('get ready');
% Deselect one
axesManager.registerClick([13, 2]);
assert(all(axesManager.selected == [1, 2]),'d');

% =========== TEST SHIFTING ==========
% 1 and 2 selected shift right with control down
% 2 will be unselected and 4 selected
keyInterpreter.controlDown = true;
axesManager.moveHorizontal(1);
assert(all(axesManager.selected == [2, 4]),'e');
assert(all(axesManager.rightUL == [1, 12]), 'f');
assert(all(axesManager.downUL == [11, 1]), 'g');
assert(all(axesManager.downRightUL == [11, 12]), 'h');

keyInterpreter.controlDown = false;
axesManager.moveVertical(-1);
assert(all(axesManager.selected == [2, 4]),'e');
assert(all(axesManager.rightUL == [-4, 12]), 'f');
assert(all(axesManager.downUL == [11, 1]), 'g');
assert(all(axesManager.downRightUL == [6, 12]), 'h');

% =========== ENSURE PROPER SELECTION ==========
axesManager.registerClick([1,1]);
axesManager.ensureProperSelection();
assert(isempty(axesManager.selected));

axesManager.registerClick([15, 15]);
axesManager.ensureProperSelection();
assert(all(axesManager.selected == [4, 2, 3]));

% =========== TEST BRINGING TO FRONT ===========
keyInterpreter.controlDown = false;
axesManager.registerClick([5, 15]);
axesManager.bringSelectedToFront();
assert(all(axesManager.order == [2, 1, 3, 4]));

axesManager.registerClick([5, 15]);
keyInterpreter.controlDown = true;
axesManager.registerClick([15, 5]);
axesManager.registerClick([15, 15]);
axesManager.bringSelectedToFront();
assert(all(axesManager.order == [2, 3, 4, 1]));







rmdir(dirPath,'s');