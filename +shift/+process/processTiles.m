
function processTiles(filePaths, imageSize, rightUL, downUL, foundChannels)
    numTilesR = size(filePaths,1);
    numTilesC = size(filePaths,2);
    
    [tileSize, grid, numTilesR, numTilesC] = shift.process.getGridAndTileSize(imageSize, rightUL,...
            downUL, numTilesR, numTilesC);

    %----------------------------------------------------------------------
    %Determine minimum R and minimum C (could be less than zero since
    %shifting tiles)
    topLeftUL = grid(1,1,:);
    bottomUL = grid(end,1,:);
    minC = max(topLeftUL(2),bottomUL(2));
    rightUL = grid(1,end,:);
    minR = max(topLeftUL(1),rightUL(1));
    %----------------------------------------------------------------------
    dirName = createImageDir();
    %----------------------------------------------------------------------
    documentScanInfo(dirName, numTilesR, numTilesC, foundChannels);
    %----------------------------------------------------------------------
    %Add a waitbar
    fileNum = 0;
    fileNumMax = numTilesR * numTilesC;
    waitH = waitbar(fileNum/fileNumMax,strcat('Processing file: 1 of ',int2str(fileNumMax)));
    %----------------------------------------------------------------------
    for r = minR:tileSize(1):(minR + (tileSize(1) * (numTilesR - 1)))
        for c = minC:tileSize(2):(minC + (tileSize(2) * (numTilesC - 1)))
            fileNum = fileNum + 1;
            %--------------------------------------------------------------
            % Calculate and display waitbar statistics
            if ~ishandle(waitH)
                waitH = waitbar(fileNum/fileNumMax,strcat('Processing file: ',int2str(fileNum), ' of ',int2str(fileNumMax)));
            else
                waitbar(fileNum/fileNumMax,waitH,strcat('Processing file: ',int2str(fileNum), ' of ',int2str(fileNumMax)));
            end
            %--------------------------------------------------------------
            % Paint all images within r --> r + rSize &&
            % c --> c + cSize onto the canvas
            canvases = shift.process.generateCanvases(r, c, filePaths, imageSize,...
                tileSize, grid);
            %--------------------------------------------------------------
            saveCanvases(canvases, dirName, fileNum, foundChannels);
            %--------------------------------------------------------------
        end
    end
    if ishandle(waitH)
        delete(waitH);
    end
end

function saveCanvases(canvases, dirName, fileNum, foundChannels)
    % Save the canvases
    % First get three digit index
    indexStr = [];
    if fileNum < 10
        indexStr = strcat('00',int2str(fileNum));
    elseif fileNum < 100
        indexStr = strcat('0',int2str(fileNum));
    else
        indexStr = strcat(int2str(fileNum));
    end
    % Save the corresponding channel for each of the canvases
    for index = 1:numel(canvases)
        fileName = cell2mat(foundChannels(index));
        fileName = [fileName,indexStr];
        filePath = [dirName,filesep,fileName,'.tif'];
        canvas = cell2mat(canvases(index));
        imwrite(canvas, filePath);
        
%         t = Tiff(filePath,'w');
% 
%         % http://www.mathworks.com/help/matlab/import_export/exporting-to-images.html
%         tags.ImageLength   = size(canvas,1);
%         tags.ImageWidth    = size(canvas,2);
%         tags.Photometric   = Tiff.Photometric.MinIsBlack;
%         tags.BitsPerSample = 64;
%         tags.SampleFormat  = Tiff.SampleFormat.IEEEFP;
%         tags.RowsPerStrip  = 16;
%         tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tags.SamplesPerPixel = size(canvas,3);
% 
%         t.setTag(tags);
%         t.write(canvas);
    end
end

function dirName = createImageDir()
    %Add a folder to store the new image files in
    dirRoot = 'ModifiedImages';
    dirName = 'ModifiedImages';
    suffix = 1;
    while(exist(dirName) == 7) %while dirName is name of folder
        dirName = strcat(dirRoot,int2str(suffix));
        suffix = suffix + 1;
    end
    %----------------------------------------------------------------------
    %Create the directory if it does not already exist
    mkdir(dirName);
end
function documentScanInfo(dirName, numTilesR, numTilesC, foundChannels)
    %Add a text file which lists the number of rows, columns, and channels
    fid = fopen(strcat(dirName,'/ScanInfo.txt'),'wt');
    fprintf(fid,strcat('Number of rows: ',int2str(numTilesR),'\n'));
    fprintf(fid,strcat('Number of columns: ', int2str(numTilesC),'\n'));
    fprintf(fid,'Layout Orientation:\n');
    fprintf(fid,'1 2 3\n4 5 6\n7 8 9\n');
    fprintf(fid,strcat('Channels: ','\n'));
    for channel = foundChannels
        channel = cell2mat(channel);
        fprintf(fid,strcat(channel,'\n'));
    end
end