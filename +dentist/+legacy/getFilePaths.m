% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% $$$ GN: It looks like this guy populates Hs.filePaths rather than
% returning a matrix.

%--------------------------------------------------------------------------
% getFilePaths returns a matrix of size M by N by C where M is number of
% tile-rows in scan, N is number of tile-columns in scan, and C is the 
% number of channels.  At each location is a cell containing the filepath
% corresponding to tileRow M, tileCol N and channel #C.  The first layer
% contains the dapi filepaths and the layers after than follow the ordering
% of foundChannels.  For example, if foundChannels =
% [{'tmr'},{'dapi'},{'alexa'}] then layer1 --> 'dapi', layer 2 --> 'tmr',
% and layer3 --> 'alexa'
% Hs.layoutIndex, Hs.rows, Hs.cols, and Hs.foundChannels are necessary
% fields for this function to work
%--------------------------------------------------------------------------

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% $$$ GN: This guy is ripe for a unit test.

function Hs = getFilePaths(Hs)
    filePaths = cell(Hs.rows,Hs.cols,numel(Hs.foundChannels));
    dirPath = Hs.dirPath;
    nameExt = Hs.nameExt;
    foundChannels = Hs.foundChannels;
    
    numFiles = Hs.rows * Hs.cols;
    div = round(numFiles / 20);
    div = max(div,1);
    waitH = [];
    %Only show waitabar if number of files is greater than cutOff
    cutOff = 100;
    if numFiles > cutOff
        waitH = waitbar(0,'Getting file-paths');
    end
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: This should be refactored so that the switch/case only sets
    % the things that are different for each case, and then a common
    % routine goes through and does the work. 
    
    
    switch Hs.layoutIndex
        case 1
            %Row no-snake
            %lay1 = [1,2,3;4,5,6;7,8,9];
            index = 1;
            for row = 1:Hs.rows
                rowIndex = row;
                for col = 1:Hs.cols
                    colIndex = col;
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 2
            %Row snake
            %lay2 = [1,2,3;6,5,4;7,8,9];
            index = 1;
            colIndex = 1;
            for row = 1:Hs.rows
                rowIndex = row;
                for col = 1:Hs.cols
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if mod(row,2) ~= 0 && colIndex ~= Hs.cols
                        colIndex = colIndex + 1;
                    elseif mod(row,2) == 0 && colIndex ~= 1
                        colIndex = colIndex - 1;
                    end
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 3
            %Row-flipped no-snake
            %lay3 = [3,2,1;6,5,4;9,8,7];
            index = 1;
            for row = 1:Hs.rows
                rowIndex = row;
                for col = Hs.cols:-1:1
                    colIndex = col;
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 4
            %Row-flipped snake
            %lay4 = [3,2,1;4,5,6;9,8,7];
            index = 1;
            colIndex = Hs.cols;
            for row = 1:Hs.rows
                rowIndex = row;
                for col = 1:Hs.cols
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if mod(row,2) ~= 0 && colIndex ~= 1
                        colIndex = colIndex - 1;
                    elseif mod(row,2) == 0 && colIndex ~= Hs.cols
                        colIndex = colIndex + 1;
                    end
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 5
            %Col no-snake
            %lay5 = [1,4,7;2,5,8;3,6,9];
            index = 1;
            for col = 1:Hs.cols
                colIndex = col;
                for row = 1:Hs.rows
                    rowIndex = row;
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 6
            %Col snakes
            %lay6 = [1,6,7;2,5,8;3,4,9];
            index = 1;
            rowIndex = 1;
            for col = 1:Hs.cols
                colIndex = col;
                for row = 1:Hs.rows
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if mod(col,2) ~= 0 && rowIndex ~= Hs.rows
                        rowIndex = rowIndex + 1;
                    elseif mod(col,2) == 0 && rowIndex ~= 1
                        rowIndex = rowIndex - 1;
                    end
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 7
            %Col-flipped no-snake
            %lay7 = [3,6,9;2,5,8;1,4,7];
            index = 1;
            for col = 1:Hs.cols
                colIndex = col;
                for row = Hs.rows:-1:1
                    rowIndex = row;
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 8
            %Col-flipped snake
            %lay8 = [3,4,9;2,5,8;1,6,7];
            index = 1;
            rowIndex = Hs.rows;
            for col = 1:Hs.cols
                colIndex = col;
                for row = 1:Hs.rows
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if mod(col,2) ~= 0 && rowIndex ~= 1
                        rowIndex = rowIndex - 1;
                    elseif mod(col,2) == 0 && rowIndex ~= Hs.rows
                        rowIndex = rowIndex + 1;
                    end
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 9
            %Col and row flipped no snake
            %lay9 = [9,6,3;8,5,2;7,4,1]
            index = 1;
            for col = Hs.cols:-1:1
                colIndex = col;
                for row = Hs.rows:-1:1
                    rowIndex = row;
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end
        case 10
            %Col and row flipped snake
            %[9,4,3;8,5,2;7,6,1]
            index = 1;
            rowIndex = Hs.rows;
            for col = Hs.cols:-1:1
                colIndex = col;
                for row = 1:Hs.rows
                    filePaths = updateFilePaths(filePaths,rowIndex,colIndex,index,dirPath,nameExt,foundChannels);
                    index = index + 1;
                    distFromEnd = Hs.cols - colIndex;
                    if mod(distFromEnd,2) == 0 && rowIndex > 1
                        rowIndex = rowIndex - 1;
                    elseif mod(distFromEnd,2) ~= 0 && rowIndex < Hs.rows
                        rowIndex = rowIndex + 1;
                    end
                    if numFiles > cutOff && mod(index,div) == 0 
                        if ~ishandle(waitH)
                            waitH = waitbar(index/numFiles,'Getting file-paths');
                        else
                            waitbar(index/numFiles,waitH,'Getting file-paths');
                        end
                    end
                end
            end     
    end
    if ishandle(waitH)
        delete(waitH);
    end
    Hs.filePaths = filePaths;
end
%--------------------------------------------------------------------------
% The main getFilePaths method contains the for-loop logic which sends the
% following variables to this method:
%       filePaths       The variable which this method updates - defined
%                       above
%       row,col         Row and col of tile location
%       index           The file-number. ex tmr025 has index of 25
%       dirPath         Filepath to parent directory
%       nameExt         Image extension (.tif or .TIF)
%       foundChannels   ex. [{'tmr'},{'dapi'},{'alexa'}]
%--------------------------------------------------------------------------
function filePaths = updateFilePaths(filePaths,row,col,index,dirPath,nameExt,foundChannels)
    %Get three digit index
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Use sprintf to format with the correct number of zeros
    % indexStr = sprintf('%03d',index);
    
    
    indexStr = [];
    if index < 10
        indexStr = strcat('00',int2str(index));
    elseif index < 100
        indexStr = strcat('0',int2str(index));
    else
        indexStr = strcat(int2str(index));
    end
    % Get the dapi image path
    s = filesep;

    pathDAPI = strcat(dirPath,s,'dapi',indexStr,nameExt);
    filePaths(row,col,1) = mat2cell(pathDAPI);
    %Get the other channel paths
    pathIndex = 2;
    for channel = foundChannels
        if ~strcmp(channel,'dapi') %We already have dapi
            path = strcat(dirPath,s,channel,indexStr,nameExt);
            filePaths(row,col,pathIndex) = mat2cell(path{1});
            pathIndex = pathIndex + 1;
        end
    end
end