%--------------------------------------------------------------------------
% Some scans are skewed such that the tiles need to be shifted in addition
% to being adjusted for overlap
%
% The user assigns the row-shifts and col-shifts by shifting images in the 
% the GUI and then the program generates the absolute coordinates of each 
% tile after applying these shifts - this information is calculated in
% processTiles function and stored in the local variable "grid".  New image
% dimensions are calculated which attempt to be as close to the original
% dimensions while requiring there be integer numbers of tiles in each
% direction.  
% There is inevitably a border surrounding the side-images.
% This can be filled with zeros.  However, this will result in
% imregionalmax detecting spots at the interface between the black and the
% image.  Attempts were made at sampling median values from channel images
% in order to simulate noise.  However, this method was variable and still
% resulted in innacurate spot detection.  Currently, this program simply
% crops the edges of the image as depicted below
%
%             3 3 3
%       2 2 2 3 3 3
% 1 1 1 2 2 2 3 3 3  -->  1 1 1 2 2 2 3 3 3
% 1 1 1 2 2 2 6 6 6  -->  1 1 1 2 2 2 6 6 6
% 1 1 1 5 5 5 6 6 6  -->  1 1 1 5 5 5 6 6 6
% 4 4 4 5 5 5 6 6 6  -->  4 4 4 5 5 5 6 6 6
% 4 4 4 5 5 5 
% 4 4 4 
%--------------------------------------------------------------------------
function Hs = shiftTiles(Hs)
    % Add needed variables to Td structure
    Td = populateGUI(Hs);
    Td.currRow = 1;
    Td.currCol = 1;
    Td.chanIndex = 1;
    Td.rows = Hs.rows;
    Td.cols = Hs.cols;
    Td.filePaths = Hs.filePaths;
    Td.overlap = 100;
    Td.rowShift = 0;
    Td.colShift = 0;
    Td.selected = [];
    Td.order = [1,2,3,4];
    Td.tilesShifted = false;

    %These images are the ones being displayed
    Td.currImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol,Td.chanIndex)));
    Td.rightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol+1,Td.chanIndex)));
    Td.downImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol,Td.chanIndex)));
    Td.downRightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol+1,Td.chanIndex)));
    
    Td.currImage = Td.currImageOrig;
    Td.currUL = [1,1];
    Td.rightUL = [1,size(Td.currImage,1)+1];
    Td.downUL = [size(Td.currImage,1)+1,1];
    Td.downRightUL = [size(Td.currImage,1)+1,size(Td.currImage,2)+1];
    
    Td = displayImages(Td);
    % When control is down image moves 1 pixel at a time instead of 10.
    % Multiple selection is also enabled when ctrl is down
    Td.controlDown = false;
    % Handles to circle-plots are stored in this field.  Cirles are plotted
    % on images that are currently selected
    Td.circlePlots = [];
    
    guidata(Td.figH,Td);

    % DensityGUI is paused until uiresume called when either exit button
    % hit
    uiwait(Td.figH);
    
    Td = guidata(Td.figH);
    % Way of communicating to DensityGUI if processTiles was run
    Hs.tilesShifted = Td.tilesShifted;
    
    delete(Td.figH);
end

function Td = populateGUI(Hs);
    figH = figure('Position',[200 200 775 600],...
        'NumberTitle','off',...
        'Name','Shift GUI',...
        'Resize','on',...
        'Toolbar','none',...
        'MenuBar','none',...
        'Color',[0.247 0.247 0.247],...
        'CloseRequestFcn',@closeRequestCallBack,...
        'KeyPressFcn',@keyPressCallBack,...
        'KeyReleaseFcn',@keyReleaseCallBack,...
        'Visible','on');
    Td = guihandles(figH);
    Td.figH = figH;
    Td.bottomPanel = uipanel('Parent',figH,...
        'Units','normalized',...
        'BorderType','etchedin',...
        'BackgroundColor',[0.247 0.247 0.247],...
        'Visible','on',...
        'Position',[0.05,0.01,0.639,0.10]);
    Td.imgAx = axes('Parent',figH,...
        'Units','normalized',...
        'Position',[0.05,0.12,.639,.86],...
        'YDir','reverse',...
        'XTick',[],'YTick',[],...
        'Color',[1,1,1],...
        'ButtonDownFcn',@imgAxisButtonDown);
    axis equal;
    Td.nextButton  = uicontrol('Parent',Td.bottomPanel,...
        'String','Next',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.01 0.50 0.188 0.45],...
        'TooltipString','next set of images',...
        'BackgroundColor',[1 1 1],...
        'Callback',@nextSetCallBack);
    Td.prevButton  = uicontrol('Parent',Td.bottomPanel,...
        'String','Previous',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'TooltipString','previous set of images',...
        'Units','normalized',...
        'Position',[0.01 0.05 0.188 0.45],...
        'BackgroundColor',[1 1 1],...
        'Callback',@prevSetCallBack);
    Td.randomButton  = uicontrol('Parent',Td.bottomPanel,...
        'String','Random',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'TooltipString','view random location',...
        'Units','normalized',...
        'Position',[0.208 0.05 0.188 0.45],...
        'BackgroundColor',[1 1 1],...
        'Callback',@randomButtonCallBack);
    Td.analyzeButton  = uicontrol('Parent',Td.bottomPanel,...
        'String','Analyze',...
        'Style','toggle',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'TooltipString','open image in new figure window',...
        'Units','normalized',...
        'Position',[0.406 0.05 0.188 0.90],...
        'BackgroundColor',[1 1 1],...
        'Callback',@analyzeButtonCallBack);
    Td.borderCheck = uicontrol('Parent',Td.bottomPanel,...
        'Style','checkbox',...
        'String','Borders',...
        'FontSize',10,...
        'Enable','on',...
        'Value',0,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.604 0.50 0.188 0.45],...
        'ForegroundColor',[1 1 1],...
        'BackgroundColor',[0.247 0.247 0.247],...
        'Callback',@borderCheckCallBack);
    Td.contrastButton = uicontrol('Parent',Td.bottomPanel,...
        'Style','toggle',...
        'String','Contrast',...
        'FontSize',10,...
        'TooltipString','increase contrast of display',...
        'Enable','on',...
        'Value',0,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.604 0.05 0.188 0.45],...
        'BackgroundColor',[1 1 1],...
        'Callback',@contrastButtonCallBack);
    Td.foundChannels = [mat2cell('dapi')];
    for channel = Hs.foundChannels
        if ~strcmp(cell2mat(channel),'dapi')
            Td.foundChannels = [Td.foundChannels,channel];
        end
    end
    Td.locBox  = uicontrol('Parent',Td.bottomPanel,...
        'String','1 - 1 (row-col)',...
        'Style','text',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.802 0.51 0.188 0.44],...
        'BackgroundColor',[1 1 1]);    %Draw the grid
    Hs.chanPop  = uicontrol('Parent',Td.bottomPanel,...
        'Style','popup',...
        'String',Td.foundChannels,...0.225
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.802 0.05 0.188 0.44],...
        'ForegroundColor',[1 1 1],...
        'BackgroundColor',[0.247 0.247 0.247],...
        'Callback',@chanPopCallBack);
    %----------------------------------------------------------------------
    % SIDE PANEL
    %----------------------------------------------------------------------
    Td.rightPanel = uipanel('Parent',figH,...
        'Units','normalized',...
        'BorderType','etchedin',...
        'BackgroundColor',[0.247 0.247 0.247],...
        'Visible','on',...
        'Position',[0.715,0.12,0.25,0.86]);
    Td.bringFrontButton  = uicontrol('Parent',Td.rightPanel,...
        'String','Bring to Front',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.175 0.555 0.65 0.06],...
        'BackgroundColor',[1 1 1],...
        'callback',{@bringFrontButtonCallBack});    %Draw the grid
    Td.showFigureButton  = uicontrol('Parent',Td.rightPanel,...
        'String','Process Tiles',...
        'TooltipString','create new image files with current shifts',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.175 0.465 0.65 0.06],...
        'BackgroundColor',[1 1 1],...
        'callback',{@processTilesButtonCallBack});    %Draw the grid
    Td.selectButton  = uicontrol('Parent',Td.rightPanel,...
        'String','Exit',...
        'Style','toggle',...
        'TooltipString','Close GUI',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.175 0.375 0.65 0.06],...
        'BackgroundColor',[1 1 1],...
        'Callback',@selectButtonCallBack);
end
%--------------------------------------------------------------------------
% When random button hit goes to random image
%--------------------------------------------------------------------------
function randomButtonCallBack(hObject,eventData)
    Td = guidata(gcbo);
    Td.currRow = ceil(rand * (Td.rows - 1));
    Td.currCol = ceil(rand * (Td.cols - 1));
    Td.currImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol,Td.chanIndex)));
    Td.rightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol+1,Td.chanIndex)));
    Td.downImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol,Td.chanIndex)));
    Td.downRightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol+1,Td.chanIndex)));
    Td = displayImages(Td);
    Td = setFocusToFigure(Td);
    guidata(Td.figH,Td);
end
%--------------------------------------------------------------------------
% When select button hit GUI exits
%--------------------------------------------------------------------------
function selectButtonCallBack(hObject, eventData)
    Td = guidata(gcbo);
    delete(Td.figH);
    %uiresume(Td.figH);
end
%--------------------------------------------------------------------------
% When random button hit goes to random image
%--------------------------------------------------------------------------
function processTilesButtonCallBack(hObject,eventData)
    Td = guidata(gcbo);
    %----------------------------------------------------------------------
    % Determine overlap in each direction
    overlapC = Td.imageSize(2) - Td.rightUL(2) + 1;
    overlapR = Td.imageSize(1) - Td.downUL(1) + 1;
    %----------------------------------------------------------------------
    %Figure out what sizeR (row_size of each new image should be)
    widthR = ((Td.imageSize(1) * Td.rows) - (overlapR * (Td.rows - 1)) ...
                - overlapR * Td.rows);
    numRows = ceil(widthR/Td.imageSize(1));
    sizeR = round(widthR/numRows);
    display(sizeR);
    %----------------------------------------------------------------------
    %Figure out what size (col_size of each new image should be)
    widthC = ((Td.imageSize(2) * Td.cols) - (overlapC * (Td.cols - 1)) ...
                - overlapC * Td.cols);
    numCols = ceil(widthC/Td.imageSize(2));
    sizeC = round(widthC/numCols);
    display(sizeC);
    %----------------------------------------------------------------------
    %Assign the absolute upper-left indices for each image into the cell
    %matrix 'grid'
    grid = cell(Td.rows,Td.cols);
    for r = 1:Td.rows
        for c = 1:Td.cols
            rBegAbs = 1 + ((Td.rightUL(1) - 1) * (c - 1)) + ((Td.downUL(1) - 1) * (r - 1));
            cBegAbs = 1 + ((Td.downUL(2) - 1) * (r - 1)) + ((Td.rightUL(2) - 1) * (c - 1));
            grid(r,c) = mat2cell([rBegAbs,cBegAbs]);
        end
    end
    %----------------------------------------------------------------------
    %Determine minimum R and minimum C (could be less than zero since
    %shifting tiles)
    first = cell2mat(grid(1,1));
    last = cell2mat(grid(end,1));
    minC = max(first(2),last(2));
    last = cell2mat(grid(1,end));
    minR = max(first(1),last(1));
    %----------------------------------------------------------------------
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
    display(dirName);
    mkdir(dirName);
    %----------------------------------------------------------------------
    %Add a text file which lists the number of rows, columns, and channels
    fid = fopen(strcat(dirName,'/ScanInfo.txt'),'wt');
    fprintf(fid,strcat('Number of rows: ',int2str(numRows),'\n'));
    fprintf(fid,strcat('Number of columns: ', int2str(numCols),'\n'));
    fprintf(fid,'Layout Orientation:\n');
    fprintf(fid,'1 2 3\n4 5 6\n7 8 9\n');
    fprintf(fid,strcat('Channels: ','\n'));
    for channel = Td.foundChannels
        channel = cell2mat(channel);
        fprintf(fid,strcat(channel,'\n'));
    end
    %----------------------------------------------------------------------
    %Determine what the noise values should be for each channel by loading
    %three random images per channel and taking the median intensity value
    % - THIS CODE IS NO LONGER UTILIZED
    noise = zeros(1,numel(Td.foundChannels));
    for chanIndex = 1:numel(Td.foundChannels)
        concat = [];
        for iter = 1:3
            randR = ceil(rand * size(Td.filePaths,1));
            randC = ceil(rand * size(Td.filePaths,2));
            filePath = cell2mat(Td.filePaths(randR,randC,chanIndex));
            concat = [concat,imread(filePath)];
        end
        value = median(double(concat(:)));
        noise(chanIndex) = value;
    end
    %----------------------------------------------------------------------
    fileNum = 0;                    %File number for each file, for example '5' for 'tmr005.tif'
    fileNumMax = numRows * numCols; %Maximum file number
    timePerFileNum = [];            %Calculated based off first 5 steps
    imgCat = [];                    %Concatenated image (used for debugging only)
    topRight = cell2mat(grid(1,end));
    botLeft = cell2mat(grid(end,1));
    %----------------------------------------------------------------------
    %Add a waitbar
    waitH = waitbar(fileNum/fileNumMax,strcat('Processing file: 1 of ',int2str(fileNumMax)));
    display('getting noise values');
    %----------------------------------------------------------------------
    for r = minR:sizeR:(minR + (sizeR * (numRows - 1)))
        %minC:sizeC:(topRight(2) + Td.imageSize(2)) - sizeC
        for c = minC:sizeC:(minC + (sizeC * (numCols - 1)))
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
            canvases = cell(1,numel(Td.foundChannels));
            for index = 1:numel(Td.foundChannels)
                canvases(1,index) = mat2cell(zeros(sizeR,sizeC));
            end
            for rInd = 1:size(grid,1);
                for cInd = 1:size(grid,2);
                    topL = cell2mat(grid(rInd,cInd));
                    topR = [topL(1),topL(2) + Td.imageSize(2) - 1];
                    botL = [topL(1) + Td.imageSize(1) - 1,topL(2)];
                    botR = topL + Td.imageSize;
                    %Checks to see if any of the points are contained in
                    %the curent canvas area
                    if contains([r,c],[sizeR,sizeC],[topL;topR;botL;botR])
                        for index = 1:numel(Td.foundChannels)
                            img = imread(cell2mat(Td.filePaths(rInd,cInd,index)));

                            rBegC = max(topL(1) - r + 1,1);
                            rEndC = min(sizeR,botL(1) - r + 1);
                            cBegC = max(topL(2) - c + 1,1);
                            cEndC = min(sizeC,topR(2) - c + 1);
                            
                            rBegI = max(r - topL(1) + 1,1);
                            rEndI = min(Td.imageSize(1),(r + sizeR - 1) - topL(1) + 1);
                            cBegI = max(c - topL(2) + 1,1);
                            cEndI = min(Td.imageSize(2),(c + sizeC - 1) - topL(2) + 1);
                            
                            canvas = cell2mat(canvases(1,index));
                            canvas(rBegC:rEndC,cBegC:cEndC) = img(rBegI:rEndI,cBegI:cEndI);
                            canvases(1,index) = mat2cell(canvas);
                        end
                    end
                end
            end
            %--------------------------------------------------------------
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
            for index = 1:numel(Td.foundChannels)
                fileName = cell2mat(Td.foundChannels(index));
                fileName = [fileName,indexStr];
                fileName = [dirName,filesep,fileName,'.tif'];
                canvas = cell2mat(canvases(index));

                t = Tiff(fileName,'w');
                
                % http://www.mathworks.com/help/matlab/import_export/exporting-to-images.html
                tags.ImageLength   = size(canvas,1);
                tags.ImageWidth    = size(canvas,2);
                tags.Photometric   = Tiff.Photometric.MinIsBlack;
                tags.BitsPerSample = 64;
                tags.SampleFormat  = Tiff.SampleFormat.IEEEFP;
                tags.RowsPerStrip  = 16;  
                tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                tags.SamplesPerPixel = 1;

                t.setTag(tags);
                t.write(canvas);
            end
            %--------------------------------------------------------------
        end
    end
    if ishandle(waitH)
        delete(waitH);
    end
    Td.tilesShifted = true;
    guidata(Td.figH,Td);
end
%--------------------------------------------------------------------------
% Returns true if any of the four locations in locs [row1,col1,...] in locs
% is contained within the box defined by upper-left index (ulIndex) and
% the [row-width,col-width] contained in imageSize
%--------------------------------------------------------------------------
function isContained = contains(ulIndex,imageSize,locs)
    topL = locs(1,:);
    topR = locs(2,:);
    botL = locs(3,:);
    botR = locs(4,:);
    isContained = false;

    if numel(find(ulIndex(1) <= topL(1):botL(1) & topL(1):botL(1) <= ulIndex(1) + imageSize(1) - 1)) >= 1 ...
            && numel(find(ulIndex(2) <= topL(2):topR(2) & topL(2):topR(2) <= ulIndex(2) + imageSize(2) - 1)) >= 1
        isContained = true;
    end
end

%--------------------------------------------------------------------------
% Brings currently selected images to front.  This affects the display but
% does not affect how processTiles will operate
%--------------------------------------------------------------------------
function bringFrontButtonCallBack(hObject,eventData)
    Td = guidata(gcbo);
    if numel(Td.selected) == 1
        Td.order(Td.order == Td.selected) = [];
        Td.order = [Td.selected,Td.order];
        Td = displayImages(Td);
    %If multiple are selected, bring them all to front, but keep the same
    %relative ordering between them
    elseif numel(Td.selected) > 1 && numel(Td.selected) < 4
        % selIndex is parallel to Td.selected with the corresponding
        % indexes in Td.order
        selIndex = [];
        for sel = Td.selected
            index = find(Td.order == sel);
            selIndex = [selIndex,index];
        end
        %Start with value in selected for which the corresponding value in
        %selIndex is highest and add to front
        [~,inds] = sort(selIndex,'descend');
        %Delete the values from Td.order that we will be adding
        for sel = Td.selected
            Td.order(Td.order == sel) = [];
        end
        %Add the values
        for ind = inds
            Td.order = [Td.selected(ind),Td.order];
        end
        Td = displayImages(Td);
    end
    Td = setFocusToFigure(Td);
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% WARNING!!!!  JAVAFRAME WILL BE DEPRECATED SOON!?!?! Who knows when but
% this is the only viable option to return focus to the main figure after
% using one of the uicontrol objects.
%--------------------------------------------------------------------------
function Td = setFocusToFigure(Td)
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    javaFrame = get(Td.figH,'JavaFrame');
    javaFrame.getAxisComponent.requestFocus;
end
%--------------------------------------------------------------------------
% Functions to change Td.controlDown switch and move image as directed by
% arrow keys
%--------------------------------------------------------------------------
function keyPressCallBack(hObject,eventData)
    Td = guidata(gcbo);
    if Td.controlDown == false && strcmp(eventData.Key,'control')
        Td.controlDown = true;
    elseif strcmp(eventData.Key,'uparrow')
        if ~Td.controlDown
            Td = moveVertical(Td,-10);
        else
            Td = moveVertical(Td,-1);
        end
        Td = displayImages(Td);
    elseif strcmp(eventData.Key,'downarrow')
        if ~Td.controlDown
            Td = moveVertical(Td,10);
        else
            Td = moveVertical(Td,1);
        end
        Td = displayImages(Td);
    elseif strcmp(eventData.Key,'rightarrow')
        if ~Td.controlDown
            Td = moveHorizontal(Td,10);
        else
           Td = moveHorizontal(Td,1); 
        end
        Td = displayImages(Td);
    elseif strcmp(eventData.Key,'leftarrow')
        if ~Td.controlDown
            Td = moveHorizontal(Td,-10);
        else
            Td = moveHorizontal(Td,-1);
        end
        Td = displayImages(Td);
    end
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Move all selected images (except upper-left) vertically by inc # of
% pixels
%--------------------------------------------------------------------------
function Td = moveVertical(Td,inc)
    Td = ensureProperSelection(Td);
        
    for selected = Td.selected
        switch selected
            case 1
%                 Td.currUL(1) = Td.currUL(1) + inc;
            case 2
                Td.rightUL(1) = Td.rightUL(1) + inc;
            case 3
                Td.downUL(1) = Td.downUL(1) + inc;
            case 4
                Td.downRightUL(1) = Td.downRightUL(1) + inc;
        end
    end
end

%--------------------------------------------------------------------------
% Move all selected images (except upper-left) horizontally by inc # of
% pixels
%--------------------------------------------------------------------------
function Td = moveHorizontal(Td,inc)
    Td = ensureProperSelection(Td);
    for selected = Td.selected
        switch selected
            case 1
%                 Td.currUL(2) = Td.currUL(2) + inc;
            case 2
                Td.rightUL(2) = Td.rightUL(2) + inc;
            case 3
                Td.downUL(2) = Td.downUL(2) + inc;
            case 4
                Td.downRightUL(2) = Td.downRightUL(2) + inc;
        end
    end
end

%--------------------------------------------------------------------------
% The scan is being adjusted by shifting the columns and rows incrementally
% but uniformly.  For this reason, if image 3 is being moved then image 4
% should be moved, and if image 2 is being moved then image 4 should be
% moved -->  1 2
%            3 4
%--------------------------------------------------------------------------
function Td = ensureProperSelection(Td)
    if numel(find(Td.selected == 2 | Td.selected == 3)) >= 1 %If right or down selected
        if numel(find(Td.selected == 4)) == 0 %If downRight not selected
            Td.selected = [Td.selected,4];
        end
    end
    %If downRight selected and neither right or down are selected, then add
    %these two to the selected tiles
    if numel(find(Td.selected == 4)) == 1 && numel(find(Td.selected == 2 | Td.selected == 3)) == 0
        Td.selected = [Td.selected,2];
        Td.selected = [Td.selected,3];
    end
end

%--------------------------------------------------------------------------
% Functions to change Td.controlDown switch to false upon release
%--------------------------------------------------------------------------
function keyReleaseCallBack(hObject,eventData)
    Td = guidata(gcbo);
    if Td.controlDown == true && strcmp(eventData.Key,'control')
        Td.controlDown = false;
    end
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Called when click in Hs.imgAxis.  Allows user to select images.  Multiple
% selection enabled when ctrl is down
%--------------------------------------------------------------------------
function imgAxisButtonDown(hObject,eventdata)
    Td = guidata(gcbo);
    point = get(Td.imgAx,'CurrentPoint');
    r = point(1,2);
    c = point(1,1);
    % 1,2,3,4 corresponding to curr, right, down, downRight
    location = -1;
    %Check in order of priority so overlap does not affect location
    for index = 1:numel(Td.order)
        locInspect = Td.order(index);
        switch locInspect
            case 1
                if r >= Td.currUL(1) && r <= (Td.currUL(1) + size(Td.currImage,1))  && c >= Td.currUL(2) && c <= (Td.currUL(2) + size(Td.currImage,2))
                    location = 1;
                    break;
                end
            case 2
                if r >= Td.rightUL(1) && r <= (Td.rightUL(1) + size(Td.rightImage,1))  && c >= Td.rightUL(2) && c <= (Td.rightUL(2) + size(Td.rightImage,2))
                    location = 2;
                    break;
                end
            case 3
                if r >= Td.downUL(1) && r <= (Td.downUL(1) + size(Td.downImage,1))  && c >= Td.downUL(2) && c <= (Td.downUL(2) + size(Td.downImage,2))
                    location = 3;
                    break;
                end
            case 4
                if r >= Td.downRightUL(1) && r <= (Td.downRightUL(1) + size(Td.downRightImage,1))  && c >= Td.downRightUL(2) && c <= (Td.downRightUL(2) + size(Td.downRightImage,2))
                    location = 4;
                    break;
                end
        end
    end

    if Td.controlDown && numel(find(Td.selected == location)) == 0
        Td.selected = [Td.selected,location];
    elseif numel(find(Td.selected == location)) == 1 && Td.controlDown == true || location ~= 1 && numel(find(Td.selected == location)) == 1 && numel(Td.selected) == 1
        Td.selected(Td.selected == location) = [];
    else
        Td.selected = location;
    end
    if isfield(Td,'circlePlots')
        for p = Td.circlePlots
            if ishandle(p)
                delete(p);
            end
        end
    end
    Td = drawCircles(Td);

    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Contrast of image is increased when contrast button is down.  This method
% only needs to recall displayImages since displayImages checks the state
% of contrastButton before displaying
%--------------------------------------------------------------------------
function contrastButtonCallBack(hObject,eventdata)
    Td = guidata(gcbo);
    Td = displayImages(Td);
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Called when channel is changed
%--------------------------------------------------------------------------
function chanPopCallBack(hObject,eventdata)
    Td = guidata(gcbo);
    set(Td.contrastButton,'Value',0);
    Td.chanIndex = get(hObject,'Value');
    Td.currImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol,Td.chanIndex)));
    Td.rightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol+1,Td.chanIndex)));
    Td.downImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol,Td.chanIndex)));
    Td.downRightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol+1,Td.chanIndex)));
    Td = displayImages(Td);
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% displayImages checks for state of borderCheck
%--------------------------------------------------------------------------
function borderCheckCallBack(hObject,eventdata)
    Td = guidata(gcbo);
    Td = displayImages(Td);
    Td = setFocusToFigure(Td);
    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% New figure opened with currently displayed images
%--------------------------------------------------------------------------
function analyzeButtonCallBack(hObject,events)
    Td = guidata(gcbo);
    figure,imcontrast(imshow(scale(Td.imgCat)));
end

%--------------------------------------------------------------------------
% Called when figure is closed
%--------------------------------------------------------------------------
function closeRequestCallBack(hObject,events)
    if isequal(get(hObject,'waitstatus'),'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end
end

%--------------------------------------------------------------------------
% Moves to the next set of images and updates display
%--------------------------------------------------------------------------
function nextSetCallBack(hObject,events)
    Td = guidata(gcbo);
    Td.currCol = Td.currCol + 1;
    if Td.currCol + 1 > Td.cols
        Td.currCol = 1;
        Td.currRow = Td.currRow + 1;
        if Td.currRow + 1 > Td.rows
            Td.currRow = 1;
        end
    end  
    Td.currImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol,Td.chanIndex)));
    Td.rightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol+1,Td.chanIndex)));
    Td.downImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol,Td.chanIndex)));
    Td.downRightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol+1,Td.chanIndex)));
    Td = displayImages(Td);
    Td = setFocusToFigure(Td);

    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Moves to previous set of images and updates display
%--------------------------------------------------------------------------
function prevSetCallBack(hObject,events)
    Td = guidata(gcbo);
    Td.currCol = Td.currCol - 1;
    if Td.currCol <= 0
        Td.currCol = Td.cols - 1;
        Td.currRow = Td.currRow - 1;
        if Td.currRow <= 0
            Td.currRow = Td.rows - 1;
        end
    end
    Td.currImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol,Td.chanIndex)));
    Td.rightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow,Td.currCol+1,Td.chanIndex)));
    Td.downImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol,Td.chanIndex)));
    Td.downRightImageOrig = imread(cell2mat(Td.filePaths(Td.currRow+1,Td.currCol+1,Td.chanIndex)));
    
    Td.currImage = Td.currImageOrig;
    Td = displayImages(Td);
    Td = setFocusToFigure(Td);

    guidata(gcbo,Td);
end

%--------------------------------------------------------------------------
% Draws circles on selected images.  Called by displayImages and 
% imgAxisButtonDown
%--------------------------------------------------------------------------
function Td = drawCircles(Td)
    %Draw circles on selected images
    for selected = Td.selected
       switch selected
           case 1
               r = round(size(Td.currImage,1)/2);
               c = round(size(Td.currImage,2)/2);
               cH = circle(c,r,20);
               set(cH,'HitTest','off');
               Td.circlePlots = [Td.circlePlots,cH];
           case 2
               r = round(size(Td.rightImage,1)/2);
               c = round(size(Td.currImage,2) + size(Td.rightImage,2)/2);
               cH = circle(c,r,20);
               set(cH,'HitTest','off');
               Td.circlePlots = [Td.circlePlots,cH];
           case 3
               r = round(size(Td.currImage,1) + size(Td.downImage,1)/2);
               c = round(size(Td.downImage,2)/2);
               cH = circle(c,r,20);
               set(cH,'HitTest','off');
               Td.circlePlots = [Td.circlePlots,cH];
           case 4
               r = round(size(Td.rightImage,1) + size(Td.downRightImage,1)/2);
               c = round(size(Td.downImage,2) + size(Td.downRightImage,2)/2);
               cH = circle(c,r,20);
               set(cH,'HitTest','off');
               Td.circlePlots = [Td.circlePlots,cH];
       end
    end

end

function Td = displayImages(Td)
    set(Td.locBox,'String',strcat('R-C: ',int2str(Td.currRow),' - ',int2str(Td.currCol)));
    Td.currImage = Td.currImageOrig;
    minCurr = min(Td.currImage(:));
    maxCurr = max(Td.currImage(:));
    canvas = zeros(size(Td.currImage,1) * 2,size(Td.currImage,2) * 2);
    % Images whose index are at the front of Td.order should be drawn on
    % top.  For this reason, images are painted on the canvas by starting at
    % the end of Td.order and proceeding forward
    for index = numel(Td.order):-1:1
        loc = Td.order(index);
        borderWidth = 4;
        switch loc
            case 1
                rBeg = max(1,Td.currUL(1));
                cBeg = max(1,Td.currUL(2));
                rEnd = min(Td.currUL(1) + size(Td.currImage,1) - 1,size(canvas,1));
                cEnd = min(Td.currUL(2) + size(Td.currImage,2) - 1,size(canvas,2));
                rBeg2 = [];
                cBeg2 = [];
                if Td.currUL(1) >= 1
                    rBeg2 = 1;
                else 
                    rBeg2 = 2 + abs(Td.currUL(1));
                end
                if Td.currUL(2) >= 1
                    cBeg2 = 1;
                else 
                    cBeg2 = 2 + abs(Td.currUL(2));
                end
                currPiece = Td.currImage(rBeg2:(rEnd - rBeg + rBeg2),cBeg2:(cEnd - cBeg + cBeg2));
                if get(Td.borderCheck,'Value') == 1
                    currPiece((end-borderWidth):end,1:end) = inf;
                    currPiece(1:end,(end-borderWidth):end) = inf;
                end
                canvas(rBeg:rEnd,cBeg:cEnd) = currPiece;
            case 2
                Td.rightImage = Td.rightImageOrig;
                minRight = min(Td.rightImage(:));
                maxRight = max(Td.rightImage(:));
                rBeg = max(1,Td.rightUL(1));
                cBeg = max(1,Td.rightUL(2));
                rEnd = min(Td.rightUL(1) + size(Td.rightImage,1) - 1,size(canvas,1));
                cEnd = min(Td.rightUL(2) + size(Td.rightImage,2) - 1,size(canvas,2));
                rBeg2 = [];
                cBeg2 = [];
                if Td.rightUL(1) >= 1
                    rBeg2 = 1;
                else 
                    rBeg2 = 2 + abs(Td.rightUL(1));
                end
                if Td.rightUL(2) >= 1
                    cBeg2 = 1;
                else 
                    cBeg2 = 2 + abs(Td.rightUL(2));
                end
                rightPiece = Td.rightImage(rBeg2:(rEnd - rBeg + rBeg2),cBeg2:(cEnd - cBeg + cBeg2));
                if get(Td.borderCheck,'Value') == 1
                    rightPiece(1:end,1:borderWidth) = inf;
                    rightPiece((end-borderWidth):end,1:end) = inf;
                end
                canvas(rBeg:rEnd,cBeg:cEnd) = rightPiece;
            case 3
                Td.downImage = Td.downImageOrig;
                minDown = min(Td.downImage(:));
                maxDown = max(Td.downImage(:));
                rBeg = max(1,Td.downUL(1));
                cBeg = max(1,Td.downUL(2));
                rEnd = min(Td.downUL(1) + size(Td.downImage,1) - 1,size(canvas,1));
                cEnd = min(Td.downUL(2) + size(Td.downImage,2) - 1,size(canvas,2));
                rBeg2 = [];
                cBeg2 = [];
                if Td.downUL(1) >= 1
                    rBeg2 = 1;
                else 
                    rBeg2 = 2 + abs(Td.downUL(1));
                end
                if Td.downUL(2) >= 1
                    cBeg2 = 1;
                else 
                    cBeg2 = 2 + abs(Td.downUL(2));
                end
                downPiece = Td.downImage(rBeg2:(rEnd - rBeg + rBeg2),cBeg2:(cEnd - cBeg + cBeg2));
                if get(Td.borderCheck,'Value') == 1
                    downPiece(1:borderWidth,1:end) = inf;
                    downPiece(1:end,end-borderWidth:end) = inf;
                end
                canvas(rBeg:rEnd,cBeg:cEnd) = downPiece;
            case 4
                Td.downRightImage = Td.downRightImageOrig;
                minDownRight = min(Td.downRightImage(:));
                maxDownRight = max(Td.downRightImage(:));
                rBeg = max(1,Td.downRightUL(1));
                cBeg = max(1,Td.downRightUL(2));
                rEnd = min(Td.downRightUL(1) + size(Td.downRightImage,1) - 1,size(canvas,1));
                cEnd = min(Td.downRightUL(2) + size(Td.downRightImage,2) - 1,size(canvas,2));
                if Td.downRightUL(1) >= 1
                    rBeg2 = 1;
                else 
                    rBeg2 = 2 + abs(Td.downRightUL(1));
                end
                if Td.downRightUL(2) >= 1
                    cBeg2 = 1;
                else 
                    cBeg2 = 2 + abs(Td.downRightUL(2));
                end
                downRightPiece = Td.downRightImage(rBeg2:(rEnd - rBeg + rBeg2),cBeg2:(cEnd - cBeg + cBeg2));
                if get(Td.borderCheck,'Value') == 1
                    downRightPiece(1:borderWidth,1:end) = inf;
                    downRightPiece(1:end,1:borderWidth) = inf;
                end
                canvas(rBeg:rEnd,cBeg:cEnd) = downRightPiece;
        end
    end
                
 
    Td.imageSize = size(Td.currImage);
    
    Td.imgCat = canvas;
    Td.canvas = canvas;
    set(Td.imgAx,'xlim',[0,(Td.imageSize(2) * 2) - (Td.overlap * 2)],'ylim',[0,(Td.imageSize(1) * 2) - (Td.overlap * 2)]);

    % Use the median of the min and max intensity values from each image 
    % to scale the displayed image
    minInt = median(double([minCurr,minDown,minRight,minDownRight]));
    maxInt = median(double([maxCurr,maxDown,maxRight,maxDownRight]));
    imgCatTemp = scale(Td.imgCat,[minInt,maxInt]);
    % Multiply by 2 if contrast is selected
    if get(Td.contrastButton,'Value') == 1
        imgCatTemp = imgCatTemp * 2;
    end
    imgH = imshow(imgCatTemp,'Parent',Td.imgAx);
    set(imgH,'ButtonDownFcn',@imgAxisButtonDown);

    Td = drawCircles(Td);
end

%--------------------------------------------------------------------------
% Called by drawCircles method to plot circle
%--------------------------------------------------------------------------
function h = circle(x,y,r)
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit);
    hold off
end