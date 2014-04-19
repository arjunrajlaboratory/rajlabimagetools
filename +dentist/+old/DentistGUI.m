%% DensityGUI
% A graphical user interface to find cells with high spot counts

%% Description
% 
%% Filename Enforcement
% Uniform file name schemes are used in the Raj lab for image stack files.
% Fluorescent channel images use short names followed by N-digit number. 
% The used names are {'tmr','alexa','cy','gfp','nir'}
% DAPI (nuclear stain) and transmission images should follow the same
% numbering scheme.


function varargout = DensityGUIc(varargin)
    %======================================================
    % Global variables are all stored in "Hs" structure,
    % aka "handles", the common place to store app data
    % in a MATLAB GUI program. "Hs" makes for cleaner code
    % and "handles" doesn't apply to all the data types we
    % store in it.
    %======================================================

    %--------------------------------------------------------------
    % Look for image files in the current working directory. If we
    % don't find any, ask the user to navigate to the image files
    % using the GUI file browser. We check again for 'data***.mat'
    % and then the image files 
    %--------------------------------------------------------------
    
    
    % $$$ GN: Put the image file finding and providing into its own
    % function or class. 
    
    
    Hs.dirPath = pwd; %pwd returns path to current folder
    Hs.dirOrig = Hs.dirPath; %Needed for uploading colormap.gif
    warning off;
    display('Getting image files');
    [Hs.foundChannels,Hs.fileNums,Hs.imgExts] = getImageFilesCustom(Hs.dirPath);
    if isempty(Hs.fileNums)  % no image files here
        fprintf(1,'Could not find any image files!\n');
        yn = input('Navigate to the directory with your files? y/n [y]','s');
        if isempty(yn); yn = 'y'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            Hs.dirPath = uigetdir(pwd,'Navigate to image files');
            if Hs.dirPath == 0;  % User pressed cancel 
                return;  % quit the GUI
            end
            [Hs.foundChannels,Hs.fileNums,Hs.imgExts] = getImageFilesCustom(Hs.dirPath);
            if isempty(Hs.fileNums)
                error('Could not find image files (eg ''tmr001.tif'' etc) to segment');
            end
        else
            return;  % user did not want to navigate to image files, quit GUI
        end
    end
    [~, numImgs] = size(Hs.fileNums);
    %Get number of rows and columns from user
    Hs.rows = input('Enter the number of rows: ');
    Hs.cols = input('Enter the number of columns: ');
    % Check for invalid dimensions - dimensions have to match the number of
    % files available
    if Hs.rows < 1 || Hs.cols < 1 || (Hs.rows * Hs.cols) ~= numImgs
        error('Invalid range for dimensions');
    end
    %Find the if the extension is .TIF or .tif
    for index = 1:numel(Hs.foundChannels)
        if strcmp(Hs.imgExts(index),'.TIF') || strcmp(Hs.imgExts(index),'.tif') 
            if strcmp(Hs.imgExts(index),'.TIF')
                Hs.nameExt = '.TIF';
            else
                Hs.nameExt = '.tif';
            end
        end
    end

    Hs = processAndDisplay(Hs);
end

%--------------------------------------------------------------------------
% Determine which spots are active at given threshold and then assign
% following fields to Hs:
% Hs.centroidMap    [numSpots; ...] where each row corresponds to the rows
%                                   of Hs.centroids
% Hs.spotMax        The maximum number of spots associated with a single
%                   centroid.  Needed for proper scaling with the color map
%                   in Hs.imageLevel of 2
% Hs.spotMap        [centroidIndex,active; ...] where rows correspond to rows of 
%                   Hs.spots and centroidIndex the row in Hs.centroid.
%                   active is either 1 or 0 corresponding to if spot is
%                   active at current threshold
%--------------------------------------------------------------------------
function Hs = activateSpotsAndCentroidMap(Hs)
    Hs.spots = cell2mat(Hs.chanSpots(Hs.chanIndex));

    Hs.spotMap = cell2mat(Hs.chanSpotMaps(Hs.chanIndex));
    % Only set spots > threshold to active
    Hs.spotMap(:,2) = Hs.spots(:,3) > Hs.threshold;
    % Deactivate any that have been deleted by user
    if ~isempty(Hs.chanDeleted)
        delSpots = cell2mat(Hs.chanDeleted(Hs.chanIndex));
        Hs.spotMap(delSpots,2) = 0;
    end

    spotMapFilt = Hs.spotMap(Hs.spotMap(:,2) == 1,1);
    
    spotMapFilt(spotMapFilt(:,1) == -1,:) = [];
    tab = tabulate(spotMapFilt);

    %Second column contains if active
    Hs.centroidMap = tab(:,2);
    % Since tabulation might not result in all centroids represented (even
    % those with zeros) - pad to ensure same size as Hs.centroids
    if size(Hs.centroidMap,1) < size(Hs.centroids,1)
       length = size(Hs.centroids,1) - size(Hs.centroidMap,1);
       padding = zeros(length,1);
       Hs.centroidMap = [Hs.centroidMap;padding];
    end
    
    Hs.centroidMap(:,2) = 1;
    Hs.centroidMap(Hs.centDeleted,2) = 0;
    padding = [];
    if size(Hs.centroidMap,1) < size(Hs.centroids,1)
        padding = zeros(size(Hs.centroids,1) - size(Hs.centroidMap,1),2);
        Hs.centroidMap = [Hs.centroidMap;padding];
    end
    Hs.spotMax = max(Hs.centroidMap(:,1));
end

function applyFilterButtonCallBack(hObject, eventData)
    Td = guidata(gcbo);
    Hs = guidata(Td.parentFig);
    
    valid = true;
    % Check Td.filterVals
    for index = 1:size(Td.filterVals,1)
       if Td.filterVals(index,1) > Td.filterVals(index,2)
           valid = false;
       end
    end
    if valid
        delete(Td.figH);
        set(Hs.filterCheckBox,'Value',1);
        Hs.filterVals = Td.filterVals;
        Hs = populateCentroidBox(Hs);
    else
        display('Invalid ranges');
    end
    
    guidata(Hs.figH,Hs);
end
%--------------------------------------------------------------------------
% This is called when click is made in figure.  It is called before any of
% the specific buttonDownListeners are clicked (for example it will be
% called before imgAxisButtonDown).  The motion-listeners can only be
% attached to the figure hObject.  By making this a field,
% imgAxisButtonDown and thumbAxisButtonDown can attach the appropriate
% motion-listener to Hs.hObject.
%--------------------------------------------------------------------------
function buttonDownCallBack(hObject,eventdata,handles)
    Hs = guidata(gcbo);
    Hs.hObject = hObject;
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Motion function attached by imgAxisButtonDown. Called while mouse
% button is moved and pressed on Hs.imgAx axis
%--------------------------------------------------------------------------
function buttonMove (hObject, dummy)
    Hs = guidata(gcbo);
    center = get(Hs.imgAx,'CurrentPoint');
    xlim = get(Hs.imgAx,'XLIM'); xlim=xlim(1,2);
    ylim = get(Hs.imgAx,'YLIM'); ylim=ylim(1,2);
    %----------------------------------------------------------------------
    % Display the zoom-rectangle - Reset the second coordinate to current 
    % cursor position if within bounds of image axis.  This will cause the 
    % second position to be the last coordinate contained within imgAx if 
    % cursor goes off screen
    %----------------------------------------------------------------------
    if get(Hs.zoomButton,'Value') == 1 && center(1,1) <= xlim && center(1,2) <= ylim
        if isfield(Hs,'rectangle') && ishandle(Hs.rectangle)
            delete(Hs.rectangle)
        end
        
        Hs.p2Click = center;
        hold on
        width = abs(Hs.p1Click(1,1) - Hs.p2Click(1,1));
        height = abs(Hs.p1Click(1,2) - Hs.p2Click(1,2));
        if width < 1
            width = 1;
        end
        if height < 1
            height = 1;
        end
        Hs.rectangle = rectangle('Position',[min(Hs.p1Click(1,1),Hs.p2Click(1,1)),min(Hs.p1Click(1,2),Hs.p2Click(1,2)),width,height],'EdgeColor','r','Parent',Hs.imgAx);
        hold off
    %----------------------------------------------------------------------
    % Drag the image 
    %----------------------------------------------------------------------
    elseif get(Hs.dragButton,'Value') ==1 && center(1,1) <= xlim && center(1,2) <= ylim
       current = center;
       rowOffSet = 0;
       colOffSet = 0;
       if abs(round(Hs.p1Click(1,1) - current(1,1))) > 0
           colOffSet = round(Hs.p1Click(1,1) - current(1,1));
           Hs.p1Click(1,1) = current(1,1);    
       end
       if abs(round(Hs.p1Click(1,2) - current(1,2))) > 0
           rowOffSet = round(Hs.p1Click(1,2) - current(1,2));
           Hs.p1Click(1,2) = current(1,2);
       end
       %Determine the previous center
       rowC = (Hs.ulIndex(1,1) + Hs.row_zoom/2);
       colC = (Hs.ulIndex(1,2) + Hs.col_zoom/2);
       %Calculate the new center using the offsets
       rowC = rowC + rowOffSet;
       colC = colC + colOffSet;
       if abs(colOffSet) > 0 || abs(rowOffSet) > 0
           Hs = setULIndex(Hs,[colC,rowC]);
           Hs = plotImage(Hs);
       end
    end
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Motion function attached by thumbAxisButtonDown. Called while mouse
% button is moved and pressed on thumbAxis
%--------------------------------------------------------------------------
function buttonMoveThumbAxis(hObject,dummy)
    Hs = guidata(gcbo);
    center = get(Hs.thumbAx,'CurrentPoint');
    Hs = setULIndex(Hs,center);
    Hs = plotImage(Hs);
    guidata(Hs.figH,Hs);
end

%----------------------------------------------------------------------
% Called when click released - It is the WindowButtonUpFcn
%----------------------------------------------------------------------
function buttonUpCallBack(hObject, eventdata, handles)
    Hs = guidata(hObject);
    if isfield(Hs,'downState') && strcmp(Hs.downState,'imgAxis')
        if get(Hs.zoomButton,'Value') == 1
            center = get(Hs.imgAx,'CurrentPoint');
            xlim = get(Hs.imgAx,'XLIM'); xlim=xlim(1,2);
            ylim = get(Hs.imgAx,'YLIM'); ylim=ylim(1,2);
            %If click-up is at same position as click-down then do a regular zoom.
            %Also ensure that click is within the limits of Hs.imgAx.
            if Hs.p1Click(1,2) == center(1,2) && Hs.p1Click(1,1) == center(1,1) && Hs.p1Click(1,1) <= xlim && Hs.p1Click(1,2) <= ylim
                zoomClick_Callback(hObject,eventdata);
                set(hObject, 'WindowButtonMotionFcn', '');
                %Else we should use the zoom-box to zoom
            elseif Hs.p1Click(1,1) <= xlim && Hs.p1Click(1,2) <= ylim
                if isfield(Hs,'rectangle') && ishandle(Hs.rectangle)
                    delete(Hs.rectangle);
                end
                set(hObject, 'WindowButtonMotionFcn', '');
                %Only do this if zoom-box is proportionally big enough.
                % Will zoom if half of min dimensions of
                % zoom box is greater than 1/40 of the current minimum zoom
                % dimension
                minDim = min(abs(Hs.p1Click(1,2) - center(1,2)),abs(Hs.p1Click(1,1) - center(1,1)));
                screenSwitch =  minDim > min(Hs.col_zoom,Hs.row_zoom)/40;
                pixelSwitch = minDim > 150;
                if screenSwitch
                    %Zoom to zoom-box dimensions
                    fitToZoomBox(Hs);
                else
                    zoomClick_Callback(hObject,eventdata);
                end
            end
        elseif get(Hs.dragButton,'Value') == 1
            set(hObject,'WindowButtonMotionFcn','');
        end
        Hs = guidata(hObject);
        Hs.downState = 'none';
        guidata(hObject,Hs);
    elseif isfield(Hs,'downState') && strcmp(Hs.downState,'thumbAxis')
        set(hObject,'WindowButtonMotionFcn','');
        Hs = guidata(hObject);
        Hs.downState = 'none';
        guidata(hObject,Hs);
    end
    set(hObject,'WindowButtonMotionFcn','');
end

function cancelButtonCallBack(hObject, eventDat)
    Hs = guidata(gcbo);
    Hs.cancelMap = true;
    guidata(Hs.figCH,Hs);
end

%--------------------------------------------------------------------------
% Called when option selected in Hs.chanPop popup
%--------------------------------------------------------------------------
function chanPopCallBack(hObject, eventdata)
    %val is the index of the spots in Hs.chanSpots
    Hs = guidata(gcbo);
    val = get(hObject,'Value');
    
    Hs.chanIndex = val;
    %Hs.firstTime is set to true as a way to communicate to plotImage that
    %the map image needs to be repainted
    Hs.firstTime = true;
    % Determine what threshold and threshold min should be.  Needed for
    % plotThreshAx.  Hs.chanThresh(N) is a cell for the Nth channel
    % containing the auto-threshold values for each tile
    Hs.threshold = Hs.chanThreshVal(val,1);
    Hs.thresholdMin = Hs.chanThreshVal(val,2);
    %     threshes = cell2mat(Hs.chanThresh(Hs.chanIndex));
    %     Hs.threshold = median(threshes);
    %     Hs.thresholdMin = median(threshes/2);
    
    % Get Hs.centroidMap, Hs.spotMap, and Hs.spotMax
    Hs = activateSpotsAndCentroidMap(Hs);
    
    % Populate centroid list box. Hs.centSort contains the sorted
    % descending order of centroid-spots
    Hs = populateCentroidBox(Hs);
    
    Hs = plotImage(Hs);
    Hs = plotThreshAx(Hs);

    guidata(gcbo,Hs);
end

function closeFigCHCallBack(hObject, eventData)
    display('Figure cannot be closed during processing');
end

%--------------------------------------------------------------------------
% Called when 'Contrast' pushbutton is clicked
%--------------------------------------------------------------------------
function contrastButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    Hs = plotImage(Hs);
    guidata(gcbo,Hs);
end

function dapiOverlayCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    if (get(hObject,'Value') == get(hObject,'Max'))%checked
        Hs.displayDapi = true;
    else %unchecked
        Hs.displayDapi = false;
    end
    Hs = plotImage(Hs);
    guidata(Hs.figH,Hs);
end
%--------------------------------------------------------------------------
% Called when "delete" button clicked
%--------------------------------------------------------------------------
function deleteButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);

    answer = questdlg('Proceeding will delete all selected spots and centroids.  Are you sure you want to continue?','Warning','Yes','No','No');
    if ~strcmp('Yes',answer)
         return;
    end
    % original size of the scan
    scanDims = [Hs.row_width Hs.col_width];
    % size of final image - number of "bins" which larger image
    % will have to funnel into
    finalDim = [1000 1000];
    % scaling factor
    scale = scanDims ./ finalDim;
    % Hs.deleted consists of two cells.  The first cell contains the
    % row-indexes of all deleted centroids and the second one the
    % row-indexes of all deleted spots
    polys = [];
    for freeHand = Hs.freeHandsH
       polys = [polys,mat2cell(freeHand.getPosition())];  
    end
        
    waitH = waitbar(0,strcat('Deleting spots channel: ',1,' of ',int2str(numel(Hs.chanSpots))));
    deletedCents = [];
    deletedSpots = [];
    % Cycle through the spots of each channel and for any whose coordinates
    % fall within one of the free-hand masks, add the index to deletedSpots
    % array
    for chanIndex = 1:numel(Hs.chanSpots)
        deletedSpots = [];
        spots = cell2mat(Hs.chanSpots(chanIndex));
        for index2 = 1:numel(polys)
            if ~ishandle(waitH)
                waitH = waitbar((chanIndex - 1)/numel(Hs.chanSpots),strcat('Deleting spots channel: ',int2str(chanIndex),' of ',int2str(numel(Hs.chanSpots))));
            else
                waitbar((chanIndex - 1)/numel(Hs.chanSpots),waitH,strcat('Deleting spots channel: ',int2str(chanIndex),' of ',int2str(numel(Hs.chanSpots))));

            end
            polygon = cell2mat(polys(index2));
            binary = inpolygon(spots(:,2),spots(:,1),polygon(:,1),polygon(:,2));
            indexes = find(binary);
            deletedSpots = [deletedSpots,(indexes)'];
        end
        deletedSpots = unique(deletedSpots);
        Hs.chanDeleted(chanIndex) = mat2cell([cell2mat(Hs.chanDeleted(chanIndex)),deletedSpots]);
    end
    if ~ishandle(waitH)
        waitH = waitbar(1,'Deleting centroids');
    else
        waitbar(1,waitH,'Deleting centroids');
    end
    % Cycle through each of the centroids and for any whose coordinates
    % fall within one of the free-hand masks, add the index to deletedCents
    % array
    for index2 = 1:numel(polys)
        polygon = cell2mat(polys(index2));
        binary = inpolygon(Hs.centroids(:,2),Hs.centroids(:,1),polygon(:,1),polygon(:,2));
        indexes = find(binary);
        deletedCents = [deletedCents,(indexes)'];
    end
    deletedCents = unique(deletedCents);
    Hs.centDeleted = [Hs.centDeleted,deletedCents];
    % Now that the deleted indexes have been updated. The free-hands can be
    % removed
    for freehand = Hs.freeHandsH
        delete(freehand);
    end
    Hs.freeHandsH = [];
%     %------------------------------------------------------------------
%     % Create the corresponding spot maps for each channel
%     % Hs.chanSpotMaps   n cells (n is # of channels) with each matrix:
%     %                   [centroidIndex] with each row corresponding to the
%     %                   index of its associated centroid
%     %------------------------------------------------------------------
    centroidSubSet = Hs.centroids;
    centroidSubSet(Hs.centDeleted,:) = inf;
    Hs.chanSpotMaps = cell(size(Hs.chanSpots));
    for index = 1:numel(Hs.chanSpots)
        if ~ishandle(waitH)
            waitH = waitbar(1,strcat('Creating centroid spot maps ',int2str(index),' of ',int2str(numel(Hs.chanSpots))));
        else
            waitbar(1,waitH,strcat('Creating centroid spot maps ',int2str(index),' of ',int2str(numel(Hs.chanSpots))));
        end
        
        spots = cell2mat(Hs.chanSpots(index));
        spotMap = knnsearch(centroidSubSet,spots(:,1:2));
        Hs.chanSpotMaps(index) = mat2cell(spotMap);
    end
    % Get Hs.centroidMap, Hs.spotMap, and Hs.spotMax
    Hs = activateSpotsAndCentroidMap(Hs);

    Hs = plotImage(Hs);
    Hs = populateCentroidBox(Hs);
    
    %------------------------------------------------------------------
    % Save the data
    %------------------------------------------------------------------
    TEMP = load(Hs.fileName);
    TEMP.chanDeleted = Hs.chanDeleted;
    TEMP.centDeleted = Hs.centDeleted;
    save(Hs.fileName,'-struct', 'TEMP','centRGBMaps','chanThreshVal','chanThresh','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','chanDeleted','centDeleted');
    delete(waitH);
    guidata(gcbo,Hs);
end


%--------------------------------------------------------------------------
% Called by histButtonCallBack.  Opens histogram in new
% figure window.  Histogram has numSpots (number of spots attributed to a
% particular centroid) on y-axis and numCentroids (number of centroids with 
% that spot count on x-axis
%--------------------------------------------------------------------------
function Hs = displayHistogram(Hs)
    figH = figure('Position',[200 100 500 500],...
        'NumberTitle','off',...
        'Name','DensityGUI',...
        'Resize','on',...
        'Toolbar','none',...
        'MenuBar','none',...
        'Color',[0.247 0.247 0.247],...
        'Visible','on');
    histAx = axes('Parent',figH,...
        'Units','normalized',...
        'Visible','on',...
        'Position',[0.10,0.10,0.86,0.86],...
        'Color',[1,1,1]);
    axes(histAx);
    [nb,xb] = hist(Hs.centroidMap,'Parent',histAx);
    bh = bar(xb,nb);
    set(bh,'FaceColor','b','EdgeColor',[0,0,0]);
end

%--------------------------------------------------------------------------
% Called when 'Drag' toggle is clicked
%--------------------------------------------------------------------------
function dragButtonCallBack (hObject,eventdata)
    Hs = guidata(gcbo);
    set(gcf,'Pointer','fleur')
    if get(Hs.zoomButton,'Value') == 1
        set(Hs.zoomButton,'Value',0);
    end
    if get(Hs.drawButton,'Value') == 1
        set(Hs.drawButton,'Value',0);
    end
    if isfield(Hs,'freeHandsH') && numel(Hs.freeHandsH) > 0
       for handle = Hs.freeHandsH
           delete(handle);
       end
       Hs.freeHandsH = [];
    end
    setDrawPanelState(Hs,0);
end

%--------------------------------------------------------------------------
% Called when 'Drag' toggle is clicked
%--------------------------------------------------------------------------
function drawButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    Hs.freeHandsH = [];
    set(gcf,'Pointer','arrow')
    if get(Hs.dragButton,'Value') == 1
        set(Hs.dragButton,'Value',0);
    end
    if get(Hs.zoomButton,'Value') == 1
        set(Hs.zoomButton,'Value',0);
    end
    
    if get(Hs.drawButton,'Value') == 1
        setDrawPanelState(Hs,1);
    else
        setDrawPanelState(Hs,0);
    end

    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Searches for data-files of appropriate format in directory dc.  If dc ==
% '' then searches current directory. Filename in the format of
% DentistDataNbyM.mat where N and M are number of rows and columns
% respectively
% Called by:
% - processAndDisplay
%--------------------------------------------------------------------------
function fileName = getDataFiles(Hs,dc)

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% $$$ GN: Suggest rewrite so that dc is an optional argument:
% if nargin < 2; dc = pwd; end

    %Filter for files containing string 'DentistData' and file extension '.mat'
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Why not DentistData*.mat without the starting *?
    
    if strcmp(dc,'')
        dataFiles = dir(strcat('*DentistData*.mat'));
    else
        dataFiles = dir(strcat(dc,'\','*DentistData*.mat'));
    end
    %The file name has number of rows and columns (see format description 
    %above). If these numbers match the inputted numbers then this file is
    %selected.
    fileName = [];
    for index = 1:numel(dataFiles)
        file = dataFiles(index);
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Replace this with a regular expression extraction
        % x = regexp(file.name,'^DentistData(\d\d*)by(\d\d*).mat$','tokens')
        % if x empty, no match (so get rid of try/catch), otherwise 
        % rows = x{1}{1}; cols = x{1}{2}
        
        try
            begInd = 12;
            endInd = strfind(file.name,'by') - 1;
            rows = str2num(file.name(begInd:endInd));
            begInd = strfind(file.name,'by')+2;
            endInd = strfind(file.name,'.mat')-1;
            cols = str2num(file.name(begInd:endInd));
            if rows == Hs.rows && cols == Hs.cols
                fileName = file.name;
                break;
            end
        catch
            % If fileName has string 'DentistData' and file extension'.mat'
            % but does not have appropriate row-column formatting, this
            % error might be thrown
            display(strcat('Ignoring',file.name,' - does not comply with naming convention'));
        end
    end
end

%--------------------------------------------------------------------------
% Called when 'Filter' button is clicked
%--------------------------------------------------------------------------
function filterButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    enableDisableFig(Hs.figH,'off');
    
    Td.filterVals = [];
    Td.parentFig = Hs.figH;
    %----------------------------------------------------------------------
    % Populate GUI
    %----------------------------------------------------------------------
    Td.figH = figure('Position',[400 150 400 405],...
        'NumberTitle','off',...
        'Name','Set Filter',...
        'Resize','off',...
        'Toolbar','none',...
        'MenuBar','none',...
        'Color',[0.247 0.247 0.247],...
        'Visible','on');
    
    position = 0.85;
    chanIndex = 1;
    for index = 1:numel(Hs.foundChannels)
        if strcmp(cell2mat(Hs.foundChannels(index)),'dapi')
            continue;
        end
        Td.filterVals = Hs.filterVals;
        chanPanel = uipanel('Parent',Td.figH,...
            'Units','normalized',...
            'BorderType','etchedin',...
            'BackgroundColor',[0.247 0.247 0.247],...
            'Visible','on',...
            'Position',[0.05,position,0.90,0.1]);
        chanLabel = uicontrol('Parent',chanPanel,...
            'Style','text',...
            'String',cell2mat(Hs.foundChannels(index)),'FontSize',14,...
            'HorizontalAlignment','Left',...
            'Units','normalized',...
            'Position',[0.025 0.1 0.2 0.8],...
            'ForegroundColor',[1 1 1],...
            'BackgroundColor',[0.247 0.247 0.247]);
        leftNumBox  = uicontrol('Parent',chanPanel,...
            'String',int2str(Hs.filterVals(chanIndex,1)),...
            'Style','edit',...
            'FontSize',10,...
            'HorizontalAlignment','Left',...
            'Units','normalized',...
            'Position',[0.3 0.1 0.2 0.8],...
            'BackgroundColor',[1 1 1],...
            'callback',{@numBoxCallBack,chanIndex,1});
        lessGreater = uicontrol('Parent',chanPanel,...
            'Style','text',...
            'String','< Counts < ','FontSize',10,...
            'HorizontalAlignment','Left',...
            'Units','normalized',...
            'Position',[0.515 0.3 0.225 0.4],...
            'ForegroundColor',[1 1 1],...
            'BackgroundColor',[0.247 0.247 0.247]);
        rightNumBox  = uicontrol('Parent',chanPanel,...
            'String',int2str(Hs.filterVals(chanIndex,2)),...
            'Style','edit',...
            'FontSize',10,...
            'HorizontalAlignment','Left',...
            'Units','normalized',...
            'Position',[0.750 0.1 0.2 0.8],...
            'BackgroundColor',[1 1 1],...
            'callback',{@numBoxCallBack,chanIndex,2});
        position = position - 0.12;
        chanIndex = chanIndex + 1;
    end
    Hs.applyFilter  = uicontrol('Parent',Td.figH,...
        'String','Apply Filter',...
        'Style','pushbutton',...
        'FontSize',10,...
        'HorizontalAlignment','Left',...
        'Units','normalized',...
        'Position',[0.05 (position + .03) 0.3 0.07],...
        'BackgroundColor',[1 1 1],...
        'Callback',@applyFilterButtonCallBack);

    
    guidata(Td.figH,Td);
    %----------------------------------------------------------------------
    %
    %----------------------------------------------------------------------
    
    uiwait(Td.figH);
    enableDisableFig(Hs.figH,'on');
    % Hs.filterVals was added on applyFilterButtonCallBack
    % so don't need to add anything
end

function filterCheckBoxCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    Hs = populateCentroidBox(Hs);
    
    guidata(Hs.figH,Hs);
end

%--------------------------------------------------------------------------
% %Called by buttonUpCallBack when click released after using zoom-box
%--------------------------------------------------------------------------
function fitToZoomBox(Hs)
    row_zoom = abs(Hs.p1Click(1,2) - Hs.p2Click(1,2));
    col_zoom = abs(Hs.p1Click(1,1) - Hs.p2Click(1,1));
    Hs.row_zoom = max(row_zoom,col_zoom);
    if Hs.row_zoom < 20
        Hs.row_zoom = 20;
    end
    Hs.col_zoom = Hs.row_zoom;
    centerC = round(min(Hs.p1Click(1,1),Hs.p2Click(1,1)) + Hs.col_zoom/2);
    centerR = round(min(Hs.p1Click(1,2),Hs.p2Click(1,2)) + Hs.row_zoom/2);
    center = [centerC,centerR];
    Hs = setULIndex(Hs,center);
    Hs = plotImage(Hs);
    guidata(gcbo,Hs);
end
%--------------------------------------------------------------------------
% Creating a "heat-map" representation of spot density.
% Following fields assigned to Hs:
% - Hs.chanMaps     N cells where each one contains a 1000by1000 "Heat-map"
%                   N corresponds to the number of channels
%--------------------------------------------------------------------------
function Hs = generateColorMap2(Hs)
    chanMapsTemp = [];
    centroidMapsTemp = [];
    chanIndex = 1;
    
    answer = questdlg('Would you like to generate the RNA Density maps.  Selecting No will still generate the centroid maps?','Map Selection','Yes','No','No');
    if strcmp('Yes',answer)
         makeRNAMaps = true;
    else
         makeRNAMaps = false;
    end
    
    myColorMap = colormap(jet(255));
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: delete
    
%     Hs.figCH = figure('Position',[300 500 225 125],...
%         'NumberTitle','off',...
%         'Name','DensityGUI',...
%         'Resize','off',...
%         'Toolbar','none',...
%         'MenuBar','none',...
%         'Color',[0.247 0.247 0.247],...
%         'CloseRequestFcn',@closeFigCHCallBack,...
%         'Visible','on');
%     Hs.figCHLabel = uicontrol('Parent',Hs.figCH,'style','text',...
%         'String','Click to skip generation of current RNA Density Map',...
%         'Units','normalized',...
%         'Visible','On',...
%         'Position',[0.15 0.45 0.70 0.4],...
%         'ForegroundColor',[1 1 1],...
%         'BackgroundColor',[0.247 0.247 0.247],...
%         'FontSize',10);
%     Hs.cancelButton = uicontrol('Parent',Hs.figCH,'style','pushbutton',...
%         'String','Skip Map','FontSize',10,...
%         'Units','normalized',...
%         'Visible','On',...
%         'BackgroundColor',[1 1 1],...
%         'Position',[0.2 0.1 0.6 0.3],...
%         'FontSize',10,...
%         'Callback',@cancelButtonCallBack);
%     guidata(Hs.figCH,Hs);
    
    for index = 1:numel(Hs.foundChannels)
        if ~strcmp(cell2mat(Hs.foundChannels(index)),'dapi')
            if ~isfield(Hs,'waitbarH') || ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar(0,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
            else
                waitbar(0,Hs.waitbarH,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
            end
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: This function has plenty of redundant comments that
            % state obvious things in the code. Delete comments and rename
            % variables if necessary. Example of a redundant comment:
            
            % Determine what the threshold is
            
            if isfield(Hs,'chanThreshVal')
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: In what scenario does this field not exist?
                % Also, why does this function have to assign the threshold of
                % Hs?
                
                Hs.threshold = Hs.chanThreshVal(chanIndex,1);
            else
                Hs.threshold = median(double(cell2mat(Hs.chanThresh(chanIndex))));
            end
            % original size of the scan
            scanDims = [Hs.row_width Hs.col_width];
            % size of final image - number of "bins" which larger image
            % will have to funnel into
            finalDim = [1000 1000];
            % Create canvas
            resampledS = zeros(finalDim);
            resampledC = zeros([finalDim,3]);
            % scaling factor
            scale = scanDims ./ finalDim;
            % Get the subset of spots and spotmap for which the intensity
            % values are above the threshold
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Rename spots2 !!
            
            spots2 = cell2mat(Hs.chanSpots(chanIndex));
            spotMap = cell2mat(Hs.chanSpotMaps(chanIndex));
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Why do we have to keep handling deleted spots? There
            % should be a way to get the non-deleted spots directly from
            % the inputs to this method or from Hs.
            
            spotDel = [];
            if ~isempty(Hs.chanDeleted)
                deleted = cell2mat(Hs.chanDeleted(chanIndex));
            else
                deleted = [];
            end
            
            spotDel(1:size(spots2,1),1) = 1;
            spotDel(deleted,1) = 0;

            spots = spots2(spots2(:,3) >= Hs.threshold & spotDel(:,1) == 1,1:3);
            spotMap = spotMap(spots2(:,3) >= Hs.threshold & spotDel(:,1) == 1,1);
            
            % Remove the spots for which spotMap value is -1.  These are
            % the spots that are greater than Hs.maxDist away from nearest
            % cell
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Should be unnecessary after refactoring the spotMap
            % to only include mapped spots.
            
            spots(spotMap == -1,:) = [];
            spotMap(spotMap == -1,:) = [];
            
            % lengthSpots and div are used for calculating percent completed
            % for waitbar display
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Rename div.
            
            lengthSpots = size(spots,1);
            div = round(lengthSpots/40);
            if div == 0
                div = 1;
            end
            if makeRNAMaps
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Extract method.
                
                % For each spot add numSpots to a box whose rows span from
                % ind(1) +/- addWidth and cols span from ind(2) +/- addWidth
                % where ind are row [row,col] of the spot and numSpots is the
                % number of spots attributed to the centroid to which this spot
                % belongs
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Rename r.
                
                for r = 1:size(spots,1)
                    if mod(r,div) == 0 || r == lengthSpots
                        if ~ishandle(Hs.waitbarH)
                            Hs.waitbarH = waitbar(r/lengthSpots,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
                        else
                            waitbar(r/lengthSpots,Hs.waitbarH,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)))
                        end
                    end
                    %----------------------------------------------------------
                    % RNA Density Map
                    %----------------------------------------------------------
                    
                    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    % $$$ GN: Lots of renaming needed in the following
                    % block.
                    
                    ind = spots(r,:);
                    addWidth = 100;
                    %----------------------------------------------------------
                    rowLowO = ind(1) - addWidth;
                    if rowLowO < 1
                        rowLowO = 1;
                    end
                    % Convert to scaled image coordinates
                    rowLow = floor((rowLowO - 1) / scale(1)) + 1;
                    %----------------------------------------------------------
                    rowHighO = ind(1) + addWidth;
                    if rowHighO > Hs.row_width
                        rowHighO = Hs.row_width;
                    end
                    % Convert to scaled image coordinates
                    rowHigh = floor((rowHighO - 1) / scale(1)) + 1;
                    %----------------------------------------------------------
                    colLowO = ind(2) - addWidth;
                    if colLowO < 1
                        colLowO = 1;
                    end
                    % Convert to scaled image coordinates
                    colLow = floor((colLowO - 1) / scale(2)) + 1;
                    %----------------------------------------------------------
                    colHighO = ind(2) + addWidth;
                    if colHighO > Hs.col_width
                        colHighO = Hs.col_width;
                    end
                    % Convert to scaled image coordinates
                    colHigh = floor((colHighO - 1) / scale(2)) + 1;
                    %----------------------------------------------------------
                    %Find the number of spots attributed to the centroid for
                    %which this spot is attributed to
                    spotAttSubSet = spots(spotMap(:,1) == spotMap(r,1) & spots(:,3) > Hs.threshold,:);
                    numSpots = size(spotAttSubSet,1);
                    value = numSpots;
                    resampledS(rowLow:rowHigh,colLow:colHigh) = resampledS(rowLow:rowHigh,colLow:colHigh) + value;
                end
                
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Extract method? Could also benefit from a lot of
                % renaming.
                % It will be good to make this a class so that different
                % strategies for displaying intensities could be used. Same
                % thing with the above section.
                
                if ~ishandle(Hs.waitbarH)
                    Hs.waitbarH = waitbar(0,strcat('Mapping intensities'));
                else
                    waitbar(0,Hs.waitbarH,strcat('Mapping intensities'));
                end
                %The indices of the zeros in the image
                zeroINDs = (resampledS == 0);
                
                % lengthCents and div used by waitbar
                lengthCents = size(Hs.centroids,1);
                div = round(lengthCents/40);
                if div == 0
                    div = 1;
                end
                centroids = Hs.centroids;
                centroids(Hs.centDeleted,:) = [];
                % centInts will contain the intensity values at the location at
                % each of the centroids
                centInts = [];
                for index = 1:size(centroids,1)
                    if mod(index,div) == 0 || index == lengthCents
                        if ~ishandle(Hs.waitbarH)
                            Hs.waitbarH = waitbar(index/lengthCents,strcat('Mapping intensities'));;
                        else
                            waitbar(index/lengthCents,Hs.waitbarH,strcat('Mapping intensities'));
                        end
                    end
                    loc = centroids(index,:);
                    % Scale to small image coordinates
                    loc(1) = floor((loc(1) - 1) / scale(1) + 1);
                    loc(1) = max(loc(1),1);
                    loc(2) = floor((loc(2) - 1) / scale(2) + 1);
                    loc(2)  = max(loc(2),1);
                    centInts = [centInts,resampledS(loc)];
                end
                [vals,INDs] = sort(centInts);
                
                % The bottom 85% of value will all have the same color.
                % Everything below the cutOff is being given the same value to
                % ensure the colormap is being utilized on the top intensity
                % values
                cutOff = vals(round(numel(centInts) * 0.85));
                resampledS(resampledS < cutOff) = cutOff;
                % Take the log to diminish effects of outliers on colormap
                resampledS = log(resampledS);
                
                gray = mat2gray(resampledS);
                rgb = ind2rgb(gray2ind(gray,255),jet(255));
                % rgb has three layers.  for the indexes that were previously
                % zero (changed when values below cutOff were set to cutOff),
                % set them to black - deal with each layer individual since
                % coordinates are linear 2D coordinates
                layer1 = rgb(:,:,1);
                layer1(zeroINDs) = 0;
                layer2 = rgb(:,:,2);
                layer2(zeroINDs) = 0;
                layer3 = rgb(:,:,3);
                layer3(zeroINDs) = 0;
                rgb = cat(3,layer1,layer2,layer3);
                
                chanMapsTemp = [chanMapsTemp,mat2cell(rgb)];
            else
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Extract method!
                
                % Creating blank map of black
                resampledS = zeros(1000,1000);
                gray = mat2gray(resampledS);
                rgb = ind2rgb(gray2ind(gray,255),jet(255));
                layer1 = rgb(:,:,1);
                layer1(:) = 0;
                layer2 = rgb(:,:,2);
                layer2(:) = 0;
                layer3 = rgb(:,:,3);
                layer3(:) = 0;
                rgb = cat(3,layer1,layer2,layer3);
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Rename chanMapsTemp
                
                chanMapsTemp = [chanMapsTemp,mat2cell(rgb)];
            end
            
            %--------------------------------------------------------------
            % Centroid map generation
            %--------------------------------------------------------------
            % lengthCents and div used by waitbar
            lengthCents = size(Hs.centroids,1);
            % Create the centroid map for this channel
            tab = tabulate(spotMap(spotMap ~= -1));
            %Second column contains if active
            centroidMap = tab(:,2);
            centroidMap(:,2) = 1;
            centroidMap(Hs.centDeleted,2) = 0;
            padding = [];
            if ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar(0/lengthCents,strcat('Mapping centroids'));
            else
                waitbar(0/lengthCents,Hs.waitbarH,strcat('Mapping centroids'));
            end
            if size(centroidMap,1) < size(Hs.centroids,1)
                padding = zeros(size(Hs.centroids,1) - size(centroidMap,1),2);
                centroidMap = [centroidMap;padding];
            end
            spotMax = max(centroidMap(:,1));
            
            centroidSet = Hs.centroids(:,1:2);
            matSort = [centroidSet,centroidMap];
            [matSort,IND] = sortrows(matSort,3);
            centroidSet = matSort(:,1:2);
            centroidMap = matSort(:,3);
            % Translate old deleted centroid rows to new rows
            centDelTrans = find(ismember(IND,Hs.centDeleted));
            
            
            for inner = 1:size(centroidSet,1)
                % Continue only if centroid has not been deleted
                if isempty(find(centDelTrans == inner))
                    if mod(inner,100) == 0
                        if ~ishandle(Hs.waitbarH)
                            Hs.waitbarH = waitbar(inner/lengthCents,strcat('Mapping centroids'));
                        else
                            waitbar(inner/lengthCents,Hs.waitbarH,strcat('Mapping centroids'));
                        end
                    end
                    ind = centroidSet(inner,1:2);
                    addWidth = 3;
                    row = floor((ind(1) - 1) / scale(1)) + 1;
                    col = floor((ind(2) - 1) / scale(2)) + 1;
                    
                    rowLow = row - addWidth;
                    if rowLow < 1
                        rowLow = 1;
                    end
                    rowHigh = row + addWidth;
                    if rowHigh > finalDim(1)
                        rowHigh = finalDim(1);
                    end
                    colLow = col - addWidth;
                    if colLow < 1
                        colLow = 1;
                    end
                    colHigh = col + addWidth;
                    if colHigh > finalDim(2)
                        colHigh = finalDim(2);
                    end

                    colorIndex = round(centroidMap(inner,1)/spotMax * size(myColorMap,1));
                    if colorIndex == 0
                        colorIndex = 1;
                    end
                    color = myColorMap(colorIndex,:);
                    resampledC(rowLow:rowHigh,colLow:colHigh,1) = color(1);
                    resampledC(rowLow:rowHigh,colLow:colHigh,2) = color(2);
                    resampledC(rowLow:rowHigh,colLow:colHigh,3) = color(3);
                end

            end
%             figure,imshow(resampledC);
            centroidMapsTemp = [centroidMapsTemp,mat2cell(resampledC)];
            chanIndex = chanIndex + 1;
        end
    end
    Hs.chanMaps = chanMapsTemp;
    Hs.centRGBMaps = centroidMapsTemp;


    delete(Hs.waitbarH);
end

function imgCat = getCatImgForChannel(Hs,chanIndex);

    %A rounded form of Hs.overlap used in image concatenation
    Hs.overlapR = round(Hs.overlap);
    %------------------------------------------------------------------
    % Initialize variables needed for image concatentation
    %------------------------------------------------------------------
    imgCat = zeros(round(Hs.row_zoom),round(Hs.col_zoom),'int16');
    imgRowWidth = Hs.imageSize(1,1);
    Hs.ulIndex(1,1) = round(Hs.ulIndex(1,1));
    Hs.ulIndex(1,2) = round(Hs.ulIndex(1,2));
    Hs.row_zoomR = round(Hs.row_zoom);
    Hs.col_zoomR = round(Hs.col_zoom);
    tileRow = floor(Hs.ulIndex(1,1) / (imgRowWidth - Hs.overlapR)) + 1;
    if tileRow > Hs.rows
        tileRow = Hs.rows;
    end
    imgColWidth = Hs.imageSize(1,2);
    tileCol = floor(Hs.ulIndex(1,2) / (imgColWidth - Hs.overlapR)) + 1;
    if tileCol > Hs.cols
        tileCol = Hs.cols;
    end
    %------------------------------------------------------------------
    % CURRENT IMAGE
    %------------------------------------------------------------------
    rowLowC = Hs.ulIndex(1,1) - ((tileRow - 1) * (imgRowWidth - Hs.overlapR));
    rowHighC = [];
    if tileRow ~= Hs.rows && rowLowC + Hs.row_zoom > imgRowWidth - Hs.overlapR
        rowHighC = imgRowWidth - Hs.overlapR;
    else
        rowHighC = rowLowC + Hs.row_zoom;
    end
    colLowC = Hs.ulIndex(1,2) - ((tileCol - 1) * (imgColWidth - Hs.overlapR));%THIS IS BECOMING ZERO
    colHighC = [];
    if tileCol ~= Hs.cols && colLowC + Hs.col_zoom > imgColWidth - Hs.overlapR
        colHighC = imgColWidth - Hs.overlapR;
    else
        colHighC = colLowC + Hs.col_zoom;
    end
    img = imread(cell2mat(Hs.filePaths(tileRow,tileCol,chanIndex + 1)));
    Hs.locationPaths(1,1) = Hs.filePaths(tileRow,tileCol,chanIndex + 1);
    if rowLowC == 0
        rowLowC = 1;
    end
    if colLowC == 0
        colLowC = 1;
    end
    imgCat(1:(rowHighC-rowLowC+1),1:(colHighC-colLowC+1)) = img(rowLowC:rowHighC,colLowC:colHighC);
    %------------------------------------------------------------------
    % DOWN IMAGE
    %------------------------------------------------------------------
    rowLowD = [];
    rowHighD = [];
    colLowD = [];
    colHighD = [];
    downAdded = false;
    if tileRow ~= Hs.rows && rowLowC + Hs.row_zoomR > Hs.imageSize(1,1) - Hs.overlapR
        downAdded = true;
        rowLowD = 1;
        rowHighD = Hs.row_zoomR - (rowHighC - rowLowC + 1);
        colLowD = colLowC;
        colHighD = colHighC;
        img = imread(cell2mat(Hs.filePaths(tileRow+1,tileCol,chanIndex + 1)));
        Hs.locationPaths(2,1) = Hs.filePaths(tileRow+1,tileCol,chanIndex + 1);
        imgCat((rowHighC - rowLowC + 2):Hs.row_zoomR,1:(colHighD-colLowD+1)) = img(rowLowD:rowHighD,colLowD:colHighD);
    end
    %------------------------------------------------------------------
    % RIGHT IMAGE
    %------------------------------------------------------------------
    rowLowR = [];
    rowHighR = [];
    colLowR = [];
    colHighR = [];
    rightAdded = false;
    if tileCol ~= Hs.cols && colLowC + Hs.col_zoom > Hs.imageSize(1,2) - Hs.overlapR
        rightAdded = true;
        rowLowR = rowLowC;
        rowHighR = rowHighC;
        colLowR = 1;
        colHighR = Hs.col_zoomR - (colHighC - colLowC + 1);
        img = imread(cell2mat(Hs.filePaths(tileRow,tileCol+1,chanIndex + 1)));
        imgCat(1:(rowHighR-rowLowR+1),(colHighC - colLowC + 2):Hs.col_zoomR) = img(rowLowR:rowHighR,colLowR:colHighR);
        Hs.locationPaths(1,2) = Hs.filePaths(tileRow,tileCol+1,chanIndex + 1);
    end
    %------------------------------------------------------------------
    % DOWN-RIGHT IMAGE
    %------------------------------------------------------------------
    rowLowDR = [];
    rowHighDR = [];
    colLowDR = [];
    colHighDR = [];
    if downAdded && rightAdded
        rowLowDR = rowLowD;
        rowHighDR = rowHighD;
        colLowDR = colLowR;
        colHighDR = colHighR;
        img = imread(cell2mat(Hs.filePaths(tileRow+1,tileCol+1,chanIndex + 1)));
        Hs.locationPaths(2,2) = Hs.filePaths(tileRow+1,tileCol+1,chanIndex + 1);
        imgCat((rowHighC - rowLowC + 2):Hs.row_zoomR,(colHighC - colLowC + 2):Hs.col_zoomR) = img(rowLowDR:rowHighDR,colLowDR:colHighDR);
    end
end

function rgb = getRGBOverlay(chanImg,dapiImg)
    chanMatrix = zeros(size(chanImg,1),size(chanImg,2),3);
    chanMatrix(:,:,1) = scale(chanImg);
    chanMatrix(:,:,2) = scale(chanImg);
    chanMatrix(:,:,3) = scale(chanImg);

    dapiMatrix = zeros(size(dapiImg,1),size(dapiImg,2),3);
    dapiMatrix(:,:,1) = scale(dapiImg);
    dapiMatrix(:,:,3) = scale(dapiImg);

    catMat = chanMatrix + dapiMatrix;

    rgb = cat(3,catMat(:,:,1),catMat(:,:,2),catMat(:,:,3));
end

%--------------------------------------------------------------------------
% Returns vector of cells (centroidMaps) where each cell contains a
% centroidMap matrix
%--------------------------------------------------------------------------
function centroidMaps = getCentroidMaps(varargin)
    Hs = cell2mat(varargin(1));
    if numel(varargin) == 2
        deleteCents = cell2mat(varargin(2));
    else
        deleteCents = true;
    end
    
    centroidMaps = [];
    numCents = size(Hs.centroids,1);
    for index = 1:numel(Hs.chanSpotMaps)
        spotMap = [];
        delSpots = [];
        spotMapFilt = [];
        tab = [];
        centroidMap = [];
        
        spots = cell2mat(Hs.chanSpots(index));
        
        spotMap = cell2mat(Hs.chanSpotMaps(index));
        spotMap(:,2) = spots(:,3) > Hs.threshold;
        spotMap(spotMap(:,1) == -1,:) = [];

        delSpots = cell2mat(Hs.chanDeleted(index));
        spotMap(delSpots,2) = 0;
        
        spotMapFilt = spotMap(spotMap(:,2) == 1,1);
        tab = tabulate(spotMapFilt);
        centroidMap = tab(:,2);
        if size(centroidMap,1) < numCents
           cat = zeros(numCents - size(centroidMap,1),1);
           centroidMap = [centroidMap;cat];
        end
        if deleteCents == true
            centroidMap(Hs.centDeleted,:) = [];
        end
        centroidMaps = [centroidMaps,mat2cell(centroidMap)];
    end
end

%--------------------------------------------------------------------------
% Called when 'Histogram' pushbutton is clicked.  This method calls
% displayHistogram
%--------------------------------------------------------------------------
function histButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    Hs = displayHistogram(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when click in Hs.imgAx axis. Motion function is attached if
% Hs.drawButton toggle is set to on
%--------------------------------------------------------------------------
function imgAxisButtonDown(hObject,eventdata)
    Hs = guidata(gcbo);
    Hs.downState = 'imgAxis';
    Hs.p1Click = get(Hs.imgAx,'CurrentPoint');

    if get(Hs.zoomButton,'Value') == 1
        %Attach the buttonmove function.  This function is called
        %while the mouse button is moved while being pressed
        set(Hs.hObject,'WindowButtonMotionFcn',@buttonMove);
    elseif get(Hs.dragButton,'Value') == 1
        Hs.p1Click = get(Hs.imgAx,'CurrentPoint');
        set(Hs.hObject,'WindowButtonMotionFcn',@buttonMove);
    elseif get(Hs.drawButton,'Value') == 1 && numel(Hs.freeHandsH) < 1
        Hs.freeHandsH = [Hs.freeHandsH,imfreehand()];
    end
    guidata(Hs.figH,Hs);
end

%--------------------------------------------------------------------------
% Called when option selected in Hs.centList
%--------------------------------------------------------------------------
function listBoxCallBack(hObject, eventdata)
    Hs = guidata(gcbo);
    index = get(hObject,'Value');
    center = Hs.centroids(Hs.centSortIX(index),:);
    %Needs to be x,y not r,c
    center = [center(1,2),center(1,1)];
    Hs.row_zoom = 800;
    Hs.col_zoom = 800;
    Hs = setULIndex(Hs,center);
    Hs = plotImage(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when "location" button clicked
%--------------------------------------------------------------------------
function locationButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    display(' ')
    display(strcat('Upper left: ',cell2mat(Hs.locationPaths(1,1))));
    display(strcat('Upper right: ',cell2mat(Hs.locationPaths(1,2))));
    display(strcat('Lower left: ',cell2mat(Hs.locationPaths(2,1))));
    display(strcat('Lower right: ',cell2mat(Hs.locationPaths(2,2))));
    display(' ')
end

%--------------------------------------------------------------------------
% Called when "map" button clicked
%--------------------------------------------------------------------------
function mapButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    answer = questdlg('Proceeding will generate a map using current deletions.  Do you want to continue?','Warning','Yes','No','No');
    if ~strcmp('Yes',answer)
         return;
    end
    Hs = generateColorMap2(Hs);
    % Communicates to plotImage that image map needs to be redrawn
    Hs.firstTime = 1;
    Hs = plotImage(Hs);
    %------------------------------------------------------------------
    % Save the data
    %------------------------------------------------------------------
    TEMP = Hs;
    TEMP.chanMaps = Hs.chanMaps;
    if ~isfield(TEMP,'chanDeleted')
        TEMP.chanDeleted = [];
    end
    if ~isfield(TEMP,'centDeleted');
        TEMP.centDeleted = [];
    end
    TEMP.centRGBMaps = Hs.centRGBMaps;
    save(Hs.fileName,'-struct', 'TEMP','foundChannels','centRGBMaps','chanThreshVal','chanThresh','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','chanDeleted','centDeleted');
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when input entered into numBoxCallBack
% side --> 1 or 2 (left or right)
%--------------------------------------------------------------------------
function numBoxCallBack(hObject,events,chanIndex,side)
    Td = guidata(gcbo);

    str = get(hObject,'String');
    % Keep if numeric or is 'inf'
    if isempty(find(ismember(str,'0123456789') == 0)) || strcmp(str,'inf')
        Td.filterVals(chanIndex,side) = str2num(str);
    else % Otherwise set to previous value
        set(hObject, 'String', num2str(Td.filterVals(chanIndex,side)));
    end
    guidata(Td.figH,Td);
end

%--------------------------------------------------------------------------
% Plots the image in Hs.imgAx axis and calls plotNumsAndCircs
% Called by: 
% - processAndDisplay, chanPopCallBack, 
% - resetThreshold_Callback, thresholdClick_Callback
% - listBoxCallBack, fitToZoomBox
% - zoomClick_Callback
%--------------------------------------------------------------------------
function Hs = plotImage(Hs)
    %Delete the plotted images. Hs.imagePlots contains handles that need to
    %be deleted upon every call to plotImage
    for p = Hs.imagePlots
        if ishandle(p)
            delete(p);
        end
    end
    Hs.imagePlots = [];
    %----------------------------------------------------------------------
    %Set thumb-axis to appropriate channel map and add bounding rectangle
    %----------------------------------------------------------------------
    set(Hs.thumbAx,'XLIM',[0,Hs.col_width],'YLIM',[0,Hs.row_width],'ButtonDownFcn',@thumbAxisButtonDown);
    img = imshow(cell2mat(Hs.chanMaps(Hs.chanIndex)),'Parent',Hs.thumbAx,'xdata',[1,Hs.col_width],'ydata',[1,Hs.row_width]);
    set(img,'ButtonDownFcn',@thumbAxisButtonDown);
    rect = rectangle('Position',[Hs.ulIndex(2),Hs.ulIndex(1),Hs.col_zoom,Hs.row_zoom],'EdgeColor','r','Parent',Hs.thumbAx);
    set(rect,'HitTest','off');
    Hs.imagePlots = [Hs.imagePlots,rect];
    Hs.locationPaths = cell(2,2);
    %----------------------------------------------------------------------
    %   INNER LEVEL OF DISPLAY - level 1
    %----------------------------------------------------------------------
    if Hs.row_zoom <= Hs.imageSize(1) && Hs.col_zoom <= Hs.imageSize(2)
        % For efficiency, bounds are changed instead of redrawing (when 
        % possible) when moving within same level.  When level is changed,
        % need to repaint
        if Hs.imageLevel ~= 1
            Hs.repaint = true;
        end
        %Communicates to other methods that at inner level of display
        Hs.imageLevel = 1;
        
        % Enable Hs.locationButton
        % outputs filenames of current location to command window
        set(Hs.locationButton,'Enable','on');
        
        imgCat = getCatImgForChannel(Hs,Hs.chanIndex);
        if isfield(Hs,'displayDapi') && Hs.displayDapi
            dapiImg = getCatImgForChannel(Hs,0);
            imgCat = getRGBOverlay(imgCat,dapiImg);
        end
        
        %------------------------------------------------------------------
        % DISPLAY CONCATENATED IMAGE
        %------------------------------------------------------------------
        if isfield(Hs,'imgCatH') && ishandle(Hs.imgCatH)
            delete(Hs.imgCatH);
        end
        %If contrast button is selected then multiply scaled version by 2
        %in order to produce brighter image
        imgTEMP = scale(imgCat);
        if get(Hs.contrastButton,'Value') == 1
            imgTEMP = imgTEMP * 3;
        end
        Hs.imgCatH = imshow(imgTEMP,'Parent',Hs.imgAx,'xdata',[Hs.ulIndex(2),Hs.ulIndex(2) + Hs.col_zoom],'ydata',[Hs.ulIndex(1),Hs.ulIndex(1) + Hs.row_zoom]);
        set(Hs.imgCatH,'ButtonDownFcn',@imgAxisButtonDown);
    %----------------------------------------------------------------------
    %   OUTER LEVELS OF DISPLAY - levels 2,3
    %----------------------------------------------------------------------
    else
        %------------------------------------------------------------------
        % If coming from the 1st image level then delete the cell-image
        % that was displayed.  For some reason, simply deleting the image
        % disturbs axis settings.  To avoid issues, axis is cleared and
        % properties are reset.
        %------------------------------------------------------------------
        if Hs.imageLevel == 1
            if isfield(Hs,'imgCatH') && ishandle(Hs.imgCatH)
                delete(Hs.imgCatH);
                cla(Hs.imgAx,'reset');
                set(Hs.imgAx,...
                        'Parent',Hs.figH,...
                        'Units','normalized',...
                        'Position',[0.019,0.022,.682,.97],...
                        'YDir','reverse',...
                        'XTick',[],'YTick',[],...
                        'Color',[0,0,0],...
                        'ButtonDownFcn',@imgAxisButtonDown);
                axis equal;
            end
        end
        % Disable Hs.locationButton
        set(Hs.locationButton,'Enable','off');
        
        if max(Hs.row_zoom,Hs.col_zoom) < 3000 %Going to 2nd image-level
            %--------------------------------------------------------------
            % If coming from 3rd image level then delete the map-image that
            % was displayed.  For some reason, simply deleting the image
            % disturbs axis settings.  To avoid issues, axis is cleared and
            % properties are reset
            %--------------------------------------------------------------
            if Hs.imageLevel ~= 2
                Hs.repaintC = true;
                Hs.repaintN = true;
            end
            if isfield(Hs,'mapImg') && ishandle(Hs.mapImg)
                delete(Hs.mapImg);
                % mapImg is shown at farthest zoomout.
                cla(Hs.imgAx,'reset');
                set(Hs.imgAx,...
                        'Parent',Hs.figH,...
                        'Units','normalized',...
                        'Position',[0.019,0.022,.682,.97],...
                        'YDir','reverse',...
                        'XTick',[],'YTick',[],...
                        'Color',[0,0,0],...
                        'ButtonDownFcn',@imgAxisButtonDown);
                        axis equal;  
            end
            if isfield(Hs,'mapCentImg') && ishandle(Hs.mapCentImg)
                delete(Hs.mapCentImg);
                % mapImg is shown at farthest zoomout in some settings
                cla(Hs.imgAx,'reset');
                set(Hs.imgAx,...
                        'Parent',Hs.figH,...
                        'Units','normalized',...
                        'Position',[0.019,0.022,.682,.97],...
                        'YDir','reverse',...
                        'XTick',[],'YTick',[],...
                        'Color',[0,0,0],...
                        'ButtonDownFcn',@imgAxisButtonDown);
                        axis equal;  
            end
            Hs.imageLevel = 2;
        else %Going to 3rd image-level
            %--------------------------------------------------------------
            % If coming from 1st or 2nd image-level then need to repaint
            % the image.  Otherwise, the reseting of bounds is all that is
            % necessary - resetting of bounds was accomplished at very
            % beginning of this method
            %--------------------------------------------------------------
            if Hs.imageLevel ~= 3
                Hs.repaintN = true;
            end
            % Display RNA Map
            if Hs.radioVal == 1
                if ~isfield(Hs,'mapImg') || ~ishandle(Hs.mapImg) || Hs.firstTime
                    if isfield(Hs,'mapCentImg') && ishandle(Hs.mapCentImg)
                        delete(Hs.mapCentImg);
                        cla(Hs.imgAx,'reset');
                        set(Hs.imgAx,...
                                'Parent',Hs.figH,...
                                'Units','normalized',...
                                'Position',[0.019,0.022,.682,.97],...
                                'YDir','reverse',...
                                'XTick',[],'YTick',[],...
                                'Color',[0,0,0],...
                                'ButtonDownFcn',@imgAxisButtonDown);
                                axis equal;  
                    end
                    Hs.mapImg = imshow(cell2mat(Hs.chanMaps(Hs.chanIndex)),'Parent',Hs.imgAx,'xdata',[1,Hs.col_width],'ydata',[1,Hs.row_width]);
                    set(Hs.mapImg,'ButtonDownFcn',@imgAxisButtonDown);
                end
            % Display Centroid Map
            else
                if isfield(Hs,'mapImg') && ishandle(Hs.mapImg)
                    delete(Hs.mapImg);
                    cla(Hs.imgAx,'reset');
                    set(Hs.imgAx,...
                            'Parent',Hs.figH,...
                            'Units','normalized',...
                            'Position',[0.019,0.022,.682,.97],...
                            'YDir','reverse',...
                            'XTick',[],'YTick',[],...
                            'Color',[0,0,0],...
                            'ButtonDownFcn',@imgAxisButtonDown);
                            axis equal;  
                end
                if ~isfield(Hs,'mapCentImg') || ~ishandle(Hs.mapCentImg) || Hs.firstTime
                    Hs.mapCentImg = imshow(cell2mat(Hs.centRGBMaps(Hs.chanIndex)),'Parent',Hs.imgAx,'xdata',[1,Hs.col_width],'ydata',[1,Hs.row_width]);
                    set(Hs.mapCentImg,'ButtonDownFcn',@imgAxisButtonDown);
                end
            end
                
            Hs.imageLevel = 3;
        end
    end
    %------------------------------------------------------------------
    % Display centroid numbers and spot circles regardless of what the
    % image level is
    %------------------------------------------------------------------
    Hs = plotNumsAndCircs(Hs);

    %----------------------------------------------------------------------
    % Set new bounds for image-axis
    %----------------------------------------------------------------------
    set(Hs.imgAx,'XLIM',[Hs.ulIndex(2),Hs.ulIndex(2) + Hs.col_zoom],'YLIM',[Hs.ulIndex(1),Hs.ulIndex(1) + Hs.row_zoom],'Position',[0.019,0.022,.682,.97]);
   
    Hs.firstTime = false;
end

%--------------------------------------------------------------------------
% Plots the centroids dots and centroid spot numbers(level 3), plots the
% centroid circles and centroid spot numbers (level 2), and plots the spot
% circles and centroid spot numbers (level 1)
% Called by: 
% - spotNCheckCallBack, spotCCheckCallBack, 
% - plotImage
%--------------------------------------------------------------------------
function Hs = plotNumsAndCircs(Hs)
    if isfield(Hs,'spotCircsH')
        for p = Hs.spotCircsH
            if ishandle(p)
                delete(p);
            end
        end
    end
    if isfield(Hs,'centNumH')
        for p = Hs.centNumH
            if ishandle(p)
                delete(p);
            end
        end
    end
    axes(Hs.imgAx);
    %----------------------------------------------------------------------
    % Plot "filler" warning on all inserted images - level 1
    %----------------------------------------------------------------------
    if Hs.imageLevel == 1
        % Determine the row/col of tiles that are currently being displayed
        tileRow = floor(Hs.ulIndex(1,1) / (Hs.imageSize(1) - Hs.overlap)) + 1;
        tileCol = floor(Hs.ulIndex(1,2) / (Hs.imageSize(2) - Hs.overlap)) + 1;
        colOffSet = 100;
        rowOffSet = 5;
        if numel(Hs.deletable) > 0 && numel(find(Hs.deletable(:,1) == tileRow & Hs.deletable(:,2) == tileCol)) >= 1 
            rowAbs = round((tileRow - 1) * (Hs.imageSize(1) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            colAbs = round((tileCol - 1) * (Hs.imageSize(2) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            if rowAbs - rowOffSet >= Hs.ulIndex(1) && rowAbs + 200 <= Hs.ulIndex(1) + Hs.row_zoom &&...
                    colAbs - colOffSet >= Hs.ulIndex(2) && colAbs + colOffSet <= Hs.ulIndex(2) + Hs.col_zoom
                t = text(colAbs-colOffSet, rowAbs-rowOffSet, 'IGNORE THIS IMAGE', 'FontSize',20,'Parent',Hs.imgAx,'Color',[1,0,0]);    % outer view
                Hs.imagePlots = [Hs.imagePlots,t];
            end
        end
        if numel(Hs.deletable) > 0 && numel(find(Hs.deletable(:,1) == tileRow+1 & Hs.deletable(:,2) == tileCol)) >= 1
            rowAbs = round((tileRow - 1 + 1) * (Hs.imageSize(1) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            colAbs = round((tileCol - 1) * (Hs.imageSize(2) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            if rowAbs - rowOffSet >= Hs.ulIndex(1) && rowAbs + 200 <= Hs.ulIndex(1) + Hs.row_zoom &&...
                    colAbs - colOffSet >= Hs.ulIndex(2) && colAbs + colOffSet <= Hs.ulIndex(2) + Hs.col_zoom
                t = text(colAbs-colOffSet, rowAbs-rowOffSet, 'IGNORE THIS IMAGE', 'FontSize',20,'Parent',Hs.imgAx,'Color',[1,0,0]);    % outer view
                Hs.imagePlots = [Hs.imagePlots,t];
            end
        end
        if numel(Hs.deletable) > 0 && numel(find(Hs.deletable(:,1) == tileRow & Hs.deletable(:,2) == tileCol+1)) >= 1
            rowAbs = round((tileRow - 1) * (Hs.imageSize(1) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            colAbs = round((tileCol - 1 + 1) * (Hs.imageSize(2) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            if rowAbs - rowOffSet >= Hs.ulIndex(1) && rowAbs + 200 <= Hs.ulIndex(1) + Hs.row_zoom &&...
                    colAbs - colOffSet >= Hs.ulIndex(2) && colAbs + colOffSet <= Hs.ulIndex(2) + Hs.col_zoom
                t = text(colAbs-colOffSet, rowAbs-rowOffSet, 'IGNORE THIS IMAGE', 'FontSize',20,'Parent',Hs.imgAx,'Color',[1,0,0]);    % outer view
                Hs.imagePlots = [Hs.imagePlots,t];
            end
        end
        if numel(Hs.deletable) > 0 && numel(find(Hs.deletable(:,1) == tileRow+1 & Hs.deletable(:,2) == tileCol+1)) >= 1
            rowAbs = round((tileRow - 1 + 1) * (Hs.imageSize(1) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            colAbs = round((tileCol - 1 + 1) * (Hs.imageSize(2) - Hs.overlap) + ((Hs.imageSize(1) - Hs.overlap) * 0.5));
            if rowAbs - rowOffSet >= Hs.ulIndex(1) && rowAbs + 200 <= Hs.ulIndex(1) + Hs.row_zoom &&...
                    colAbs - colOffSet >= Hs.ulIndex(2) && colAbs + colOffSet <= Hs.ulIndex(2) + Hs.col_zoom
                t = text(colAbs-colOffSet, rowAbs-rowOffSet, 'IGNORE THIS IMAGE', 'FontSize',20,'Parent',Hs.imgAx,'Color',[1,0,0]);    % outer view
                Hs.imagePlots = [Hs.imagePlots,t];
            end
        end
    end
        
    
    %----------------------------------------------------------------------
    % Plot dots at all centroid locations(Hs.radioVal == 1), or circles (Hs.radioVal == 2) - level 3
    %----------------------------------------------------------------------
    if Hs.radioVal == 1 && Hs.imageLevel == 3 && get(Hs.spotCCheck,'Value') == 1
        centroidView = Hs.centroids(Hs.ulIndex(2) < Hs.centroids(:,2) & Hs.centroids(:,2) < Hs.ulIndex(2) + Hs.col_zoom &...
                                        Hs.ulIndex(1) < Hs.centroids(:,1) & Hs.centroids(:,1) < Hs.ulIndex(1) + Hs.row_zoom & Hs.centroidMap(:,2) == 1,:);
        X = round(centroidView(:,2));
        Y = round(centroidView(:,1));
        hold(Hs.imgAx,'on');
        h = gscatter(X,Y);
        set(h,'HitTest','off');
        Hs.imagePlots = [Hs.imagePlots,h];
        Hs.scatterH = h;
        hold(Hs.imgAx,'off');
    end
    Hs.centNumH = [];
    %------------------------------------------------------------------
    % Plot the centroid spot numbers - level 2 and 3
    %------------------------------------------------------------------
    if get(Hs.spotNCheck,'Value') == 1
        %Get the indexes of the centroids currently being displayed
        cenIND = find(Hs.ulIndex(2) < Hs.centroids(:,2) & Hs.centroids(:,2) < Hs.ulIndex(2) + Hs.col_zoom & Hs.ulIndex(1) < Hs.centroids(:,1) & Hs.centroids(:,1) < Hs.ulIndex(1) + Hs.row_zoom & Hs.centroidMap(:,2) == 1);
        x = Hs.centroids(cenIND,2);
        y = Hs.centroids(cenIND,1);
        nums = num2cell(Hs.centroidMap(cenIND,1));
        t = [];
        if Hs.imageLevel == 1
            t = text(x-10, y+5, nums, 'FontSize',16,'Parent',Hs.imgAx,'Color',[1,1,1]);   % inner view
        elseif Hs.imageLevel == 2
            t = text(x-37, y+5, nums, 'FontSize',8,'Parent',Hs.imgAx,'Color',[1,1,1]);    % middle view
        else
            t = text(x-10, y+5, nums, 'FontSize',8,'Parent',Hs.imgAx,'Color',[1,1,1]);    % outer view
        end
        set(t,'HitTest','off');
        t = t';
        Hs.centNumH = [Hs.centNumH,t];
        Hs.imagePlots = [Hs.imagePlots,t];
    end
    %----------------------------------------------------------------------
    % This method deals with: Centroid circles (level 2), 
    % spot circles (level3).  These features are grouped
    % together since they all involve cycling through each centroid
    %----------------------------------------------------------------------
    if get(Hs.spotCCheck,'Value') == 1 || Hs.imageLevel == 2
        %------------------------------------------------------------------
        % Define the colors for the spot circles - level 1
        %------------------------------------------------------------------
        colors = {[1,0,0],...%Red
            [0,1,0],...%Blue
            [0,0,1],...%Orange
            [1,162/255,0],...%Pink
            [1,0,102/255],...%Light-blue
            [101/255,205/255,216/255],...%Purple
            [88/255,11/255,78/255],...%Greenish
            [11/255,88/255,63/255],...
            [216/255,142/255,169/255],...
            [165/255,108/255,8/255]};
        colIndex = 1;
        %Get the indexes of the centroids currently being displayed
        cenIND = find(Hs.ulIndex(2) < Hs.centroids(:,2) & Hs.centroids(:,2) < Hs.ulIndex(2) + Hs.col_zoom & Hs.ulIndex(1) < Hs.centroids(:,1) & Hs.centroids(:,1) < Hs.ulIndex(1) + Hs.row_zoom & Hs.centroidMap(:,2) == 1);
        Hs.spotCircsH = [];

        %------------------------------------------------------------------
        % Cycle through each centroid
        %------------------------------------------------------------------
        for cenI = 1:numel(cenIND)

            index = cenIND(cenI);
            %--------------------------------------------------------------
            % Plot the spot circles - level 1
            %--------------------------------------------------------------
            if get(Hs.spotCCheck,'Value') == 1 && Hs.imageLevel == 1
                spotIND = find(Hs.spotMap(:,1) == index & Hs.spotMap(:,2) == 1);
                X = Hs.spots(spotIND(:),2);
                Y = Hs.spots(spotIND(:,1),1);
                hold(Hs.imgAx,'on');
                h = plot(X,Y,'or','Parent',Hs.imgAx,'Color',cell2mat(colors(colIndex)));
                hold(Hs.imgAx,'off');
                set(h,'HitTest','off');
                Hs.spotCircsH = [Hs.spotCircsH,h];
                Hs.imagePlots = [Hs.imagePlots,h];
                colIndex = colIndex + 1;
                if colIndex > numel(colors)
                    colIndex = 1;
                end
            end
            %--------------------------------------------------------------
            % Plot the centroid circles - level 2
            %--------------------------------------------------------------
            if Hs.imageLevel == 2
                x = round(Hs.centroids(index,2));
                y = round(Hs.centroids(index,1));
                r = 60;
                colorIndex = round(Hs.centroidMap(index,1)/Hs.spotMax * size(Hs.colorMap,1));
                if colorIndex == 0
                    colorIndex = 1;
                end
                color = Hs.colorMap(colorIndex,:);
                th = 0:pi/50:2*pi;
                xunit = r * cos(th) + x;
                yunit = r * sin(th) + y;
                hold(Hs.imgAx,'on');
                h = plot(xunit, yunit,'Color',color,'Parent',Hs.imgAx,'LineWidth',3);
                set(h,'HitTest','off');
                Hs.imagePlots = [Hs.imagePlots,h];
                hold(Hs.imgAx,'off');
            end
        end
    end
end

%--------------------------------------------------------------------------
% Plots the threshold plots on Hs.thresholdAx
% Called by: 
% - processAndDisplay, chanPopCallBack, 
% - resetThreshold_Callback, thresholdClick_Callback
%--------------------------------------------------------------------------
function Hs = plotThreshAx(Hs)
    %Delete previous threshold plots
    if isfield(Hs,'threshPlots')
        for p = Hs.threshPlots
            if ishandle(p)
                delete(p);
            end
        end
    end
    Hs.threshPlots = [];
   
    table = cell2mat(Hs.chanSpotVals(Hs.chanIndex));
    
    Hs.threshXLim = table(end,1);
    maxNum = max(table(:,2));
    dataH = plot(table(:,1),log(table(:,2)),'b','Parent',Hs.thresholdAx);
    set(Hs.thresholdAx,'XLim',[0 table(end,1) + Hs.chanThreshShifts(1,Hs.chanIndex)],'YLim',[0, log(maxNum) + 1]);
    
    hold(Hs.thresholdAx,'on');
    threshH2 = plot([Hs.thresholdMin Hs.thresholdMin],[0 log(maxNum)],'r','Parent',Hs.thresholdAx); % Red line - min threshold
    threshH = plot([Hs.threshold Hs.threshold],[0 log(maxNum)],'g','Parent',Hs.thresholdAx);   % Green line - current threshold             
%     threshH2 = plot([Hs.thresholdMax Hs.thresholdMax],[0 log(maxNum)],'y','Parent',Hs.thresholdAx); % Red line - min threshold

    hold(Hs.thresholdAx,'off');
    
    Hs.threshPlots = [Hs.threshPlots,threshH,threshH2,dataH];

    set(threshH,'HitTest','off');   % make the green line non-clickable
    set(threshH2,'HitTest','off');  % make the red line non-clickable
    set(dataH,'HitTest','off');     % make the blue line non-clickable

    set(Hs.thresholdAx,'NextPlot','replacechildren','Color',[1 1 1]); % needs to be set each time
end

%--------------------------------------------------------------------------
% Populate centroid list box. Hs.centSort contains the sorted
% descending order of centroid-spots
%--------------------------------------------------------------------------
function Hs = populateCentroidBox(Hs)
    centroidMap = Hs.centroidMap(:,1);
    centroidMap(Hs.centroidMap(:,2) == 0) = -1;
    % If filter box checked, also set to -1 those that don't satisfy filter
    % Hs.filterVals
    if get(Hs.filterCheckBox,'Value') == 1
        centroidMaps = getCentroidMaps(Hs,false);
        numCents = size(cell2mat(centroidMaps(1)),1);
        % 1 if centroid active, 0 if not active
        active = ones(numCents,1);
        for chanIndex = 1:numel(centroidMaps)
            centroidMapLocal = cell2mat(centroidMaps(chanIndex));
            lowVal = Hs.filterVals(chanIndex,1);
            highVal = Hs.filterVals(chanIndex,2);
            activeInner = (centroidMapLocal > lowVal) & (centroidMapLocal < highVal);
            active = active & activeInner;
        end
        centroidMap = cell2mat(centroidMaps(Hs.chanIndex));
        centroidMap(Hs.centroidMap(:,2) == 0) = -1;
        centroidMap(active == 0) = -2;
    end
    [Hs.centSort,Hs.centSortIX] = sort(centroidMap,'descend');
    set(Hs.centList,'String',Hs.centSort);
end

%--------------------------------------------------------------------------
% Called by processAndDisplay
%--------------------------------------------------------------------------
function Hs = populateGUI(Hs)
        foundChannels = Hs.foundChannels;
        %------------------------------
        %Prepare the GUI
        %------------------------------  
        figH = figure('Position',[200 100 900 605],...
                      'NumberTitle','off',...
                      'Name','DensityGUI',...
                      'Resize','on',...
                      'Toolbar','none',...
                      'MenuBar','none',...
                      'Color',[0.247 0.247 0.247],...
                      'WindowButtonUpFcn',@buttonUpCallBack,...
                      'WindowButtonDownFcn',@buttonDownCallBack,...
                      'Visible','on');

        Hs = guihandles(figH);
        Hs.figH = figH;

        Hs.imgAx = axes('Parent',figH,...
                        'Units','normalized',...
                        'Position',[0.019,0.019,.682,.682],...
                        'YDir','reverse',...
                        'XTick',[],'YTick',[],...
                        'Color',[0,0,0],...
                        'ButtonDownFcn',@imgAxisButtonDown);
        axis equal;

        Hs.thumbAx = axes('Parent',figH,...
                          'Units','normalized',...
                          'Position',[0.710,0.680,0.136,0.2],...
                          'YDir','reverse',...
                          'Color',[1,1,1],...
                          'ButtonDownFcn',@thumbAxisButtonDown);
        axis equal;
        %----------------------------------------------------------------
        % Threshold Controls
        %----------------------------------------------------------------

        Hs.thresholdAx = axes('Parent',figH,...
                                'Units','normalized',...
                                'Position',[0.710 0.095 0.276 0.3280],...
                                'NextPlot','replacechildren',...
                                'Visible','On',...
                                'Color',[1 1 1],...
                                'ButtonDownFcn',@thresholdClick_Callback);

        Hs.thresholdL = uicontrol('Parent',figH,'style','text',...
                                'String','Threshold',...
                                'Units','normalized',...
                                'Visible','Off',...
                                'Position',[0.710 0.330 0.112 0.036],...
                                'FontSize',14);
        Hs.resetThresh = uicontrol('Parent',figH,'style','pushbutton',...
                                'String','Reset','FontSize',10,...
                                'Units','normalized',...
                                'Visible','On',...
                                'BackgroundColor',[1 1 1],...
                                'Position',[0.907 0.387 0.080 0.036],...
                                'FontSize',14,...
                                'Callback',@resetThreshold_Callback); 
        Hs.leftShiftButton = uicontrol('Parent',figH,'style','pushbutton',...
                                'String','Shift Left','FontSize',10,...
                                'Units','normalized',...
                                'Visible','On',...
                                'BackgroundColor',[1 1 1],...
                                'Position',[0.7295 0.015 0.065 0.0375],...
                                'FontSize',10,...
                                'Callback',{@shiftButtonCallBack,-1}); 
        Hs.resetShiftButton = uicontrol('Parent',figH,'style','pushbutton',...
                                'String','Reset','FontSize',10,...
                                'Units','normalized',...
                                'Visible','On',...
                                'FontSize',10,...
                                'BackgroundColor',[1 1 1],...
                                'Position',[0.8105 0.015 0.065 0.0375],...
                                'Callback',{@shiftButtonCallBack,0}); 
        Hs.rightShiftButton = uicontrol('Parent',figH,'style','pushbutton',...
                                'String','Shift Right','FontSize',10,...
                                'Units','normalized',...
                                'Visible','On',...
                                'BackgroundColor',[1 1 1],...
                                'FontSize',10,...
                                'Position',[0.8915 0.015 0.065 0.0375],...
                                'Callback',{@shiftButtonCallBack,+1}); 
        %------------------------------------------------------------------
        Hs.figTitle = uicontrol('Parent',figH,...
                                'Style','text',...
                                'String','DENTIST','FontSize',40,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.900 0.280 0.094],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247]);


        Hs.centList = uicontrol('Parent',figH,...
                                'Style','listbox',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.850 0.7180 0.136 0.1623],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@listBoxCallBack);
%         Hs.histAx = axes('Parent',figH,...
%                           'Units','normalized',...
%                           'Visible','off',...
%                           'Position',[0.710,0.38,0.276,0.25],...
%                           'Color',[1,1,1]);

        Hs.spotCCheck = uicontrol('Parent',figH,...
                                'Style','checkbox',...
                                'String','Circles',...
                                'FontSize',10,...
                                'Enable','on',...
                                'Value',1,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.630 0.080 0.0375],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@spotCCheckCallBack);

        Hs.spotNCheck = uicontrol('Parent',figH,...
                                'Style','checkbox',...
                                'String','Numbers',...
                                'Value',0,...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.790 0.630 0.080 0.0375],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@spotNCheckCallBack);
        Hs.dapiOverlay = uicontrol('Parent',figH,...
                                'Style','checkbox',...
                                'String','Dapi Overlay',...
                                'Value',0,...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.880 0.630 0.136 0.0375],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@dapiOverlayCallBack);
        Hs.filterButton = uicontrol('Parent',figH,...
                                'Style','pushbutton',...
                                'String','Filter',...
                                'Value',0,...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.850 0.680 0.068 0.0320],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@filterButtonCallBack);
        Hs.filterCheckBox = uicontrol('Parent',figH,...
                                'Style','checkbox',...
                                'String','On/Off',...
                                'Value',0,...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.919 0.680 0.067 0.0375],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@filterCheckBoxCallBack);
        channels = [];
        for channel = foundChannels
            if ~strcmp(cell2mat(channel),'dapi')
                channels = [channels,channel];
            end
        end
        Hs.chanPop  = uicontrol('Parent',figH,...
                                'Style','popup',...
                                'String',channels,...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.600 0.136 0.0300],...
                                'ForegroundColor',[1 1 1],...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Callback',@chanPopCallBack);
        Hs.zoomButton  = uicontrol('Parent',figH,...
                                'String','Zoom',...
                                'Value',1,...
                                'Style','toggle',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.850 0.590 0.045667 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@zoomButtonCallBack);
        Hs.dragButton  = uicontrol('Parent',figH,...
                                'String','Drag',...
                                'Style','toggle',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.89567 0.590 0.045667 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@dragButtonCallBack);
        Hs.drawButton  = uicontrol('Parent',figH,...
                                'String','Draw',...
                                'Style','toggle',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.941334 0.590 0.045667 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@drawButtonCallBack);
        Hs.contrastButton  = uicontrol('Parent',figH,...
                                'String','Contrast',...
                                'Style','toggle',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.52725 0.0673775 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@contrastButtonCallBack);
        Hs.saveButton  = uicontrol('Parent',figH,...
                                'String','Save',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.48775 0.0673775 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@saveCentroidMapsCallBack);
        Hs.viewButton  = uicontrol('Parent',figH,...
                                'String','View',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.710 0.44825 0.0673775 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@viewButtonCallBack);
        Hs.histButton  = uicontrol('Parent',figH,...
                                'String','Histogram',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.77988 0.52725 0.0673775 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@histButtonCallBack);
        Hs.locationButton  = uicontrol('Parent',figH,...
                                'String','Location',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'Enable','off',...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.77988 0.48775 0.0673775 0.0375],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@locationButtonCallBack);
        Hs.buttonGroup = uibuttongroup('Parent',figH,...
                                'Units','normalized',...
                                'Visible','on',...
                                'SelectionChangeFcn',@radioButtonCallBack,...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Position',[0.77988,0.44825,.207119,0.0375]);
        radioButtonRNA = uicontrol('Parent',Hs.buttonGroup,...
                                'Units','normalized',...
                                'Style','radiobutton',...
                                'Value',1,...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'FontSize',10,...
                                'Visible','on',...
                                'ForegroundColor',[1,1,1],...
                                'String','RNA Map',...
                                'Position',[0,0,0.49,1]);
        radioButtonCentroid = uicontrol('Parent',Hs.buttonGroup,...
                                'Units','normalized',...
                                'Style','radiobutton',...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'FontSize',10,...
                                'Visible','on',...
                                'ForegroundColor',[1,1,1],...
                                'String','Centroids',...
                                'Position',[.51,0,0.49,1]);
                            
        Hs.drawPanel = uipanel('Parent',Hs.figH,...
                                'Units','normalized',...
                                'BorderType','etchedin',...
                                'BackgroundColor',[0.247 0.247 0.247],...
                                'Visible','on',...
                                'Position',[0.849744,0.48775,0.137255,0.0773]);
        Hs.undoButton  = uicontrol('Parent',Hs.drawPanel,...
                                'String','Undo',...
                                'TooltipString','Undo last action',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'Enable','off',...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.03 0.515 0.455 0.455],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@undoButtonCallBack);
        Hs.deleteButton  = uicontrol('Parent',Hs.drawPanel,...
                                'String','Delete',...
                                'TooltipString','Delete selected elements',...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'Enable','off',...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.515 0.515 0.455 0.455],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@deleteButtonCallBack);
        Hs.resetButton  = uicontrol('Parent',Hs.drawPanel,...
                                'String','Reset',...
                                'Style','pushbutton',...
                                'TooltipString','Reset all deletions',...
                                'FontSize',10,...
                                'Enable','off',...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[0.03 0.03 0.455 0.455],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@resetButtonCallBack);
        Hs.mapButton  = uicontrol('Parent',Hs.drawPanel,...
                                'String','Map',...
                                'Style','pushbutton',...
                                'TooltipString','Regenerate map image',...
                                'FontSize',10,...
                                'Enable','off',...
                                'HorizontalAlignment','Left',...
                                'Units','normalized',...
                                'Position',[.515 0.03 0.455 0.455],...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@mapButtonCallBack);
end

function Hs = processAndDisplay(Hs)
%     %filePaths keeps track of the file paths.  For example filePaths(2,3)
%     %will contain the file paths of the images for the tile at row 2 and 
%     % column 3.  Each cell contains a 1 by N matrix (N being the number of
%     % channels) with DAPI first and then the other channels following
%     filePaths = cell(Hs.rows,Hs.cols,numel(Hs.foundChannels));

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% $$$ GN: cell(i, j, k) returns a 3-d cell array, but the spec suggests
% filePaths is a 2-d cell array where each element is a 1d cell array.



    % '' used to indicate current directory
    %------------------------------------------------------------------
    % Check for data-file from previous session
    %------------------------------------------------------------------
    fileName = getDataFiles(Hs,'');
    
    
    useDataFile = false;
    

    
    if size(fileName) == 0
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: This whole scenario can be moved into getDataFiles
        % itself. At the end of a getDataFiles call, it could check if
        % fileNames was empty, do this user prompting, and call itself
        % again if the user wants to try another directory.
        
        fprintf(1,'Could not data files of appropriate dimensions\n');
        yn = input('Navigate to the directory with your file? y/n [y]','s');
        if isempty(yn); yn = 'n'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            useDataFile = true; %Use data file since they indicate that they want to navigate to it
            dirPath = uigetdir(pwd,'Navigate to data files');
            if dirPath == 0;  % User pressed cancel 
                return;  % quit the GUI
            end
            fileName = getDataFiles(Hs,dirPath);
            if size(fileName) == 0
                error('Could not find data files (eg ''DentistData3by3.mat'' etc) to read');
            end
        end
    else
        %If automatically found data file, ensure that user wishes to use
        %it
        
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Reword question -> load from previously calculated, or
        % something like that.
        
        yn = input('Do you want to load from data file? y/n [y]','s');
        if isempty(yn); yn = 'y'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            useDataFile = true;
        else
            useDataFile = false;
        end 
    end
    Hs.fileName = fileName;
    %------------------------------------------------------------------
    % Load from data-file
    %------------------------------------------------------------------
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Why does one need to check both? Isn't useDataFile enough?
    % Also: probably best to use short-circuit && in these cases
    
    if size(fileName) > 0 & useDataFile
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: The two scenarios : use data file or not, should send off
        % to two different methods. The "else" to this "if" is way too far
        % away.
        
        
        % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Suggest using a different name for TEMP such as:
        % 'dataFromDisk' or some other thing dependent on the class name of
        % the object that stores the data.
        
        TEMP = load(fileName);
        Hs.chanThresh = TEMP.chanThresh;
        Hs.chanSpots = TEMP.chanSpots;
        Hs.chanSpotMaps = TEMP.chanSpotMaps;
        Hs.chanSpotVals = TEMP.chanSpotVals;
        Hs.imageSize = TEMP.imageSize;
        Hs.centroids = TEMP.centroids;
        Hs.overlap = TEMP.overlap;
        Hs.chanMaps = TEMP.chanMaps;
        Hs.nuclei = [];
        % Saved data updated 7/1/13 to inlude field called deleted.  For
        % compatibility program checks existence of field
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Turn the saved data into an object when you save it. Then
        % this kind of legacy code check can be handled by the defaults in
        % the class file and in that objects "loadobj", and can be removed
        % from here entirely.
        
        if isfield(TEMP,'chanDeleted')
            Hs.chanDeleted = TEMP.chanDeleted;
        else
            Hs.chanDeleted = cell(1,numel(Hs.foundChannels) - 1);
        end
        if isfield(TEMP,'centDeleted')
            Hs.centDeleted = TEMP.centDeleted;
        else
            Hs.centDeleted = [];
        end
        if isfield(TEMP,'deletable')
            Hs.deletable = TEMP.deletable;
        else
            Hs.deletable = [];
        end
        if isfield(TEMP,'centRGBMaps')
            Hs.centRGBMaps = TEMP.centRGBMaps;
        else
            Hs.centRGBMaps = [];
        end
        if isfield(TEMP,'chanThreshVal')
            Hs.chanThreshVal = TEMP.chanThreshVal;
            
            % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Can use dependent attributes in a class to avoid
            % having to do the next two manually every time.

            Hs.threshold = Hs.chanThreshVal(1,1);
            Hs.thresholdMin = Hs.chanThreshVal(1,2);
        else
            %------------------------------------------------------------------
            % Determine what threshold and threshold min should be.  Needed for
            % plotThreshAx.  Hs.chanThresh(N) is a cell for the Nth channel
            % containing the auto-threshold values for each tile
            %------------------------------------------------------------------
            Hs.chanThreshVal = [];
            for index = 1:numel(Hs.chanThresh)
                threshes = cell2mat(Hs.chanThresh(index));
                threshold = median(double(threshes));
                thresholdMin = min(threshes/2);
                Hs.chanThreshVal = [Hs.chanThreshVal;threshold,thresholdMin];
            end
            Hs.threshold = Hs.chanThreshVal(1,1);
            Hs.thresholdMin = Hs.chanThreshVal(1,2);
        end

            
            
        Hs.layoutIndex = TEMP.layoutIndex;
        % The dimensions of the stitched image
        Hs.row_width = Hs.imageSize(1) * Hs.rows - (Hs.overlap * (Hs.rows - 1));
        Hs.col_width = Hs.imageSize(2) * Hs.cols - (Hs.overlap * (Hs.cols - 1));
        % Will be necessary when displaying images in the cell-level
        % display (Hs.imageLevel of 1)
        if isfield(TEMP,'filePaths')
            Hs.filePaths = TEMP.filePaths;
        else
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: In what scenario will this block execute?
            
            Hs = getFilePaths(Hs);
        end
    %------------------------------------------------------------------
    % Process each tile
    %------------------------------------------------------------------
    else
        
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: This whole block should  be a standalone function or class.
        % It does so much work!
        
        
        Hs.maxDist = input('Enter the max distance in pixels a spot can be from the centroid (default is 1024):');
        if isempty(Hs.maxDist)
            Hs.maxDist = 1024;
        end
        
        % Hs.layoutIndex is added
        TEMP = getLayoutOrientation(Hs);
        Hs.layoutIndex = TEMP.layoutIndex;
        Hs = getFilePaths(Hs);
    
        Hs.overlap = input('Enter the pixel overlap (or press enter for GUI): ');
        if isempty(Hs.overlap)
            Hs = getImageOverlap(Hs);
            if Hs.tilesShifted
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: you could just clear
                % Hs, and right here change the directory and rerun the
                % program. Quite optional, though.
                
               display('Please locate the ''Modified Images'' folder and run DensityGUI'); 
               return;
            elseif Hs.shiftTilesCalled
                return;
            end
        end
        Hs.waitbarH = waitbar(0);
        Hs = processTiles(Hs,Hs.filePaths);
        display('process tiles finished');
        %The dimensions of the stitched image
        Hs.row_width = Hs.imageSize(1) * Hs.rows - (Hs.overlap * (Hs.rows - 1));
        Hs.col_width = Hs.imageSize(2) * Hs.cols - (Hs.overlap * (Hs.cols - 1));
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: This can be replaced with class defaults and we won't
        % need the comment.
        
        % Contains two cells.  The first cell has an array containing the
        % row-indexes of the deleted centroids.  The second cell has an
        % array containing the row-indexes of the deleted spots.  It can be
        % generated and saved by the user later in the program.  In case
        % the user decides not to generate it, a blank copy is saved so an
        % error is not thrown when trying to load an empty field.
        Hs.chanDeleted = cell(1,numel(Hs.foundChannels) - 1);
        Hs.centDeleted = [];
        
        %------------------------------------------------------------------
        % Create the corresponding spot maps for each channel
        % Hs.chanSpotMaps   n cells (n is # of channels) with each matrix:
        %                   [centroidIndex] with each row corresponding to the
        %                   index of its associated centroid
        % If distance greater than cuttoff (Hs.maxDist) then value is -1
        %------------------------------------------------------------------
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Extract method
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Rename chanSpotMaps. Why do we have "chan" in so many
        % names? What is this mapping between? Best to make it an
        % object/class.
        
        Hs.chanSpotMaps = cell(size(Hs.chanSpots));
        for index = 1:numel(Hs.chanSpots)
            spots = cell2mat(Hs.chanSpots(index));
            [spotMap,D] = knnsearch(Hs.centroids,spots(:,1:2));
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Is there a better way to handle such spots? Why not
            % just relegate them to some unMapped spots field. As it
            % stands, subsequent methods have to keep checking whether
            % spotMap = -1 and throwing those spots out. This change will
            % clarify code intent.
            
            spotMap(D > Hs.maxDist) = -1;
            Hs.chanSpotMaps(index) = mat2cell(spotMap);
        end
        %------------------------------------------------------------------
        % Determine what threshold and threshold min should be.  Needed for
        % plotThreshAx.  Hs.chanThresh(N) is a cell for the Nth channel
        % containing the auto-threshold values for each tile
        %------------------------------------------------------------------
        Hs.chanThreshVal = [];
        for index = 1:numel(Hs.chanThresh)
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Rename threshes -> tileThresholds
            
            threshes = cell2mat(Hs.chanThresh(index));
            threshold = median(double(threshes));
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Rename thresholdMin -> minIntensityForThreshPlot
            
            thresholdMin = min(threshes/2);
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Includes stuff that is not a thresh. Rename this.
            % What is the value of keeping this is a matrix?
            
            Hs.chanThreshVal = [Hs.chanThreshVal;threshold,thresholdMin];
        end
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Why are we going to the first channel here? 
        % Also, Seems redundant to store threshold and thresholdMin in Hs when it
        % can be calculated from chanThreshVal. Keep one or the other.
        
        Hs.threshold = Hs.chanThreshVal(1,1);
        Hs.thresholdMin = Hs.chanThreshVal(1,2);
        %------------------------------------------------------------------
        % Save the data before generating the color maps
        % - Uses blank maps in place of the color maps
        %------------------------------------------------------------------
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Why? If it is a design decision, explain.
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: More descriptive name for chanMaps. What is it?
        
        Hs.chanMaps = [];
        Hs.centRGBMaps = [];
        for index = 1:numel(Hs.foundChannels)
            if ~strcmp(cell2mat(Hs.foundChannels(index)),'dapi')
                blankMap = zeros(1000,1000);
                gray = mat2gray(blankMap);
                rgb = ind2rgb(gray2ind(gray,255),jet(255));
                layer1 = rgb(:,:,1);
                layer1(:) = 0;
                layer2 = rgb(:,:,2);
                layer2(:) = 0;
                layer3 = rgb(:,:,3);
                layer3(:) = 0;
                rgb = cat(3,layer1,layer2,layer3);
                Hs.chanMaps = [Hs.chanMaps,mat2cell(rgb)];
                Hs.centRGBMaps = [Hs.centRGBMaps,mat2cell(rgb)];
            end
        end
        name = strcat('DentistData',int2str(Hs.rows),'by',int2str(Hs.cols),'.mat');
        Hs.fileName = name;
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Why not make the Hs struct and just save that? If need to not save some stuff,
        % could use 'Transient' properties in Class.
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Break long lines with ...
        
        save(name,'-struct', 'Hs','chanThresh','chanThreshVal','foundChannels','centRGBMaps','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','filePaths','deletable');
        display('data saved');
        %------------------------------------------------------------------
        % Generate color maps for each channel
        %------------------------------------------------------------------
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Why the "2"?
        
        Hs = generateColorMap2(Hs);
        
        %------------------------------------------------------------------
        % Save the data
        %------------------------------------------------------------------
        name = strcat('DentistData',int2str(Hs.rows),'by',int2str(Hs.cols),'.mat');
        Hs.fileName = name;
        save(name,'-struct', 'Hs','chanThresh','chanThreshVal','foundChannels','centRGBMaps','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','filePaths','deletable');
    end
    %------------------------------------------------------------------
    % The structure Hs is reassigned.  These temporary variables are created
    % so that after they may be reassigned below after Hs has been
    % reassigned (reassigned in call to populateGUI)
    %------------------------------------------------------------------
    nucleiTemp = Hs.nuclei;
    centroidsTemp = Hs.centroids;
    imageSizeTemp = Hs.imageSize;
    rowsTemp = Hs.rows;
    colsTemp = Hs.cols;
    overlapTemp = Hs.overlap;
    filePathsTemp = Hs.filePaths;
    chanSpotsTemp = Hs.chanSpots;
    chanSpotVals = Hs.chanSpotVals;
    chanThreshTemp = Hs.chanThresh;
    chanSpotMapsTemp = Hs.chanSpotMaps;
    chanMapsTemp = Hs.chanMaps;
    rowWidthTemp = Hs.row_width;
    colWidthTemp = Hs.col_width;
    deletedChanTEMP = Hs.chanDeleted;
    centDeletedTEMP = Hs.centDeleted;
    foundChannelsTEMP = Hs.foundChannels;
    fileNameTEMP = Hs.fileName;
    deletableTEMP = Hs.deletable;
    centRGBMapsTEMP = Hs.centRGBMaps;
    chanThreshValTEMP = Hs.chanThreshVal;
    layoutIndexTEMP = Hs.layoutIndex;

    Hs = populateGUI(Hs);
    
    Hs.layoutIndex = layoutIndexTEMP;
    Hs.chanThreshVal = chanThreshValTEMP;
    Hs.centRGBMaps = centRGBMapsTEMP;
    Hs.deletable = deletableTEMP;
    Hs.fileName = fileNameTEMP;
    Hs.foundChannels = foundChannelsTEMP;
    Hs.centDeleted = centDeletedTEMP;
    Hs.chanDeleted = deletedChanTEMP;
    Hs.row_width = rowWidthTemp;
    Hs.col_width = colWidthTemp;
    Hs.chanMaps = chanMapsTemp;
    Hs.chanSpotMaps = chanSpotMapsTemp;
    Hs.chanSpotVals = chanSpotVals;
    Hs.chanSpots = chanSpotsTemp;
    Hs.nuclei = nucleiTemp;
    Hs.centroids = centroidsTemp;
    Hs.filePaths = filePathsTemp;
    Hs.imageSize = imageSizeTemp;
    Hs.rows = rowsTemp;
    Hs.cols = colsTemp;
    Hs.overlap = overlapTemp;
    Hs.chanThresh = chanThreshTemp;
    Hs.chanThreshShifts = zeros(1,numel(Hs.chanSpotVals));
    
    
    Hs.threshold = Hs.chanThreshVal(1,1);
    Hs.thresholdMin = Hs.chanThreshVal(1,2);
    
    % Hs.radioVal of 1 is RNA Map and Hs.radioVal of 2 is Centroid map
    Hs.radioVal = 1;
    
    % Hs.location will contain the filepaths of the images that are
    % currently in view - in level 1
    Hs.locationPaths = cell(2,2);

    %------------------------------------------------------------------
    % Initialize necessary variables
    %------------------------------------------------------------------
    % The dimensions of the stitched image
    Hs.row_width = Hs.imageSize(1) * Hs.rows - (Hs.overlap * (Hs.rows - 1));
    Hs.col_width = Hs.imageSize(2) * Hs.cols - (Hs.overlap * (Hs.cols - 1));
    % The upper-left index of the zoom-box
    Hs.ulIndex = [0,0];
    % The row_width of the zoom-box
    Hs.row_zoom = Hs.row_width;
    % The col_width of the zoom-box
    Hs.col_zoom = Hs.col_width;
    % All plots such as the centroid circles are added to this array so that
    % they can be removed before being replotted
    Hs.imagePlots = [];
    Hs.histPlots = [];
    Hs.imageMode = false;
    % Color-map for differentiating nuclei spot counts
    Hs.colorMap = colormap(jet(255));
    % Plot the image on Hs.thresholdAx from Hs.chanSpotVals
    Hs.regionalMaxValues = cell2mat(Hs.chanSpotVals(1));
    % The initial channel
    Hs.chanIndex = 1;
    % The current spots
    Hs.spots = cell2mat(Hs.chanSpots(1));
    % The current spotmap
    Hs.spotMap = cell2mat(Hs.chanSpotMaps(1));
    
    if max(Hs.row_zoom,Hs.col_zoom) <= Hs.imageSize(1)
        Hs.imageLevel = 1;
    elseif max(Hs.row_zoom,Hs.col_zoom) < 3000
        Hs.imageLevel = 2;
    else
        Hs.imageLevel = 3;
    end
    Hs.filterVals = [];
    for index = 1:(numel(Hs.foundChannels) - 1)
        Hs.filterVals = [Hs.filterVals;0,inf];
    end
   
    % Set to false the first time through processTiles. Necessary since some
    % images only display on either a change from one image level to
    % another - since no transition to signal display when starting
    % program, need a boolean 
    Hs.firstTime = true;
    % Get Hs.centroidMap, Hs.spotMap, and Hs.spotMax
    Hs = activateSpotsAndCentroidMap(Hs);

    %----------------------------------------------------------------------
    % Generate the displays
    %----------------------------------------------------------------------
    Hs = plotImage(Hs);
    % Populate centroid list box. Hs.centSort contains the sorted 
    % descending order of centroid-spots
    Hs = populateCentroidBox(Hs);
    % Plot the threshold axis
    Hs = plotThreshAx(Hs);
    
    %Save GUI data to figure
    guidata(Hs.figH, Hs);
end

%--------------------------------------------------------------------------
% processTiles(Hs,filePaths) adds the following fields to Hs:
%     Hs.nuclei         [nucleus1,nucleus2...] of class Nucleus
%     Hs.chanSpots      n cells (n is # of channels) with each matrix:
%                       [row,col,intensity] with each row corresponding to
%                       another spot
%     Hs.chanSpotVals   chanSpotVals contains n cells(n is # of channels)
%                       with each cell containing a vector of spot intensty
%                       values.  These values are sampling of intensity
%                       values for the purpose of displaying the threshold
%                       plot
%     Hs.centroids      [row,col] with each row corresponding to another
%                       centroid
%     Hs.imageSize      [row_size,col_size] of each image 
%--------------------------------------------------------------------------

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% $$$ GN: These added fields suggest being their own class.

function Hs = processTiles(Hs, filePaths)
    nuclei = [];
    centroids = [];
    chanSpots = cell(1,size(filePaths,3)-1);
    chanSpotVals = cell(1,size(filePaths,3)-1);
    chanThresh = cell(1,size(filePaths,3)-1);
    % deletable has three columns 1: row of tile 2: col of tile 3: channel
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Is there a way these columns could be known by name instead of by index?
    % In general, it will be best to avoid using matrices for things that
    % are not naturally matrices.
    
    deletable = [];
    % tileCenInds is a local (to this method) variable which contains a
    % Hs.rows by Hs.cols matrix of cells, each of which contains the
    % indexes of the centroids which belong to that corresponding tile
    tileCenInds = cell(Hs.rows,Hs.cols);
    index = 1;
    for row = 1:Hs.rows
        for col = 1:Hs.cols
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Make a helper function for this waitbar. It seems to come
            % up a a lot. The string should be specified only once.
            
            if ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar((((row-1) * Hs.cols) + col)/(Hs.rows * Hs.cols),strcat('Processing - Row: ',int2str(row),' Col: ',int2str(col)));;
            else
                waitbar((((row-1) * Hs.cols) + col)/(Hs.rows * Hs.cols),Hs.waitbarH,strcat('Processing - Row: ',int2str(row),' Col: ',int2str(col)));
            end
            %--------------------------------------------------------------
            % CURRENT IMAGE
            %--------------------------------------------------------------
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Name "chanCurrents" hard to interpret. If it is the
            % current image, call it currentImage. If it is the current
            % channel, call it currentChannel. Why is it plural?
            
            chanCurrents = [];
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Looping through the channels? -> Can try to make this
            % so that it is clear from the code itself.
              
            for ind = 2:size(filePaths,3)
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Is this loop's job just to replace bad tiles?
                
                img = imread(cell2mat(filePaths(row,col,ind)));
                if row == 1 && col == 1 && ind == 2
                    Hs.imageSize = size(img);
                end
                %----------------------------------------------------------
                % If not the the same as the other images then need to
                % substitute in another image
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Can't this be handled by a smart image-provider?
                % Also avoids the problem of if the 1st file is bad.
                
                if (~(row == 1 && col == 1) && ~isequal(size(img),Hs.imageSize))
                    badImg = img;
                    img = cell2mat(chanCurrentsOld(ind - 1));
                    
                    deletable = [deletable;row,col,ind];
                    fileName = cell2mat(filePaths(row,col,ind));
                    badFileName = strcat(fileName(1:end-4),'BAD','.tif');
                    goodFileName = fileName;
                    
                    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    % $$$ GN: Does this replace the actual file on disk?!
                    
                    display('Ignoring and replacing due to image-size: ')
                    display(goodFileName);
                    img = uint16(img);
                    tiffToFile(badImg,badFileName);
                    tiffToFile(img,goodFileName);
                end
                %----------------------------------------------------------
                chanCurrents = [chanCurrents,mat2cell(img)];
            end          
            chanCurrentsOld = chanCurrents;
            dapiCurrent = imread(cell2mat(filePaths(row,col,1)));
            %--------------------------------------------------------------
            % If not the the same as the other images then need to
            % substitute in another image
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Seems extremely similar to the block above! -> Method
            % extract. 
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: What is special about the Dapi special case?
            
            if ~(row == 1 && col == 1) && ~isequal(size(dapiCurrent),Hs.imageSize)
                badImg = dapiCurrent;
                
                dapiCurrent = dapiCurrentOld;
                deletable = [deletable,row,col,1];
                fileName = cell2mat(filePaths(row,col,1));
                badFileName = strcat(fileName(1:end-4),'BAD','.tif');
                goodFileName = fileName;
                display('Ignoring and replacing: ')
                display(goodFileName);
                tiffToFile(badImg,badFileName);
                dapiCurrent = uint16(dapiCurrent);
                tiffToFile(dapiCurrent,goodFileName);
            end
            dapiCurrentOld = dapiCurrent;
            
            %--------------------------------------------------------------
            %Crop the images to get rid of the overlap
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Extract method for cropping
            
            if row ~= Hs.rows %If not on bottom
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Rename Hs.rows -> Hs.numRows. Expect Hs.rows to be
                % an array of row numbers/identifiers/entities.
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Can use an object that contains chanCurrents and
                % dapiCurrent and define crop operations at the
                % object-level that crops all contained images.
                
                for chanCurrent = chanCurrents
                    chanCurrent = mat2cell(chanCurrent);
                    chanCurrent = chanCurrent(1:(size(chanCurrent,1) - Hs.overlap),:);
                end
                dapiCurrent = dapiCurrent(1:(size(dapiCurrent,1) - Hs.overlap),:);
            end
            if col ~= Hs.cols %If not on right side
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: Rename Hs.cols -> Hs.numCols. Expect Hs.cols to be
                % an array of cols.
                
                for chanCurrent = chanCurrents
                    chanCurrent = mat2cell(chanCurrent);
                    chanCurrent = chanCurrent(:,1:(size(chanCurrent,2) - Hs.overlap));
                end
                dapiCurrent = dapiCurrent(:,1:(size(dapiCurrent,2) - Hs.overlap));
            end
            %--------------------------------------------------------------
            % RIGHT IMAGE
            %--------------------------------------------------------------
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: These blocks about neighboring images
            % should reduce to one line each after method for the above is extracted.
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Why is Dapi getting special treatment here? Why is it
            % necessary to stitch together images from Dapi but not from
            % the FISH channels?
            
            if col ~= Hs.cols
                dapiRight = imread(cell2mat(filePaths(row,col+1,1)));
                %----------------------------------------------------------
                % If not the the same as the other images then need to
                % substitute in another image
                if ~(row == 1 && col == 1) && ~isequal(size(dapiRight),Hs.imageSize)
                    badImg = dapiRight;

                    dapiRight = dapiRightOld;
                    deletable = [deletable,row,col+1,1];
                    fileName = cell2mat(filePaths(row,col+1,1));
                    badFileName = strcat(fileName(1:end-4),'BAD','.tif');
                    goodFileName = fileName;
                    display('Ignoring and replacing: ')
                    display(goodFileName);
                    tiffToFile(badImg,badFileName);
                    dapiRight = uint16(dapiRight);
                    tiffToFile(dapiRight,goodFileName);
                end
                dapiRightOld = dapiRight;
                %----------------------------------------------------------
                %Crop the images to get rid of the overlap
                if row ~= Hs.rows %If not on bottom
                    dapiRight = dapiRight(1:(size(dapiRight,1) - Hs.overlap),:);
                end
                if (col + 1) ~= Hs.cols %If not on right side
                    dapiRight = dapiRight(:,1:(size(dapiRight,2) - Hs.overlap));
                end
            end
            %--------------------------------------------------------------
            % DOWN IMAGE
            %--------------------------------------------------------------            
            if row ~= Hs.rows
                dapiDown = imread(cell2mat(filePaths(row+1,col,1)));
                %----------------------------------------------------------
                % If not the the same as the other images then need to
                % substitute in another image
                if ~(row == 1 && col == 1) && ~isequal(size(dapiDown),Hs.imageSize)
                    badImg = dapiDown;
                
                    dapiDown = dapiDownOld;
                    deletable = [deletable,row+1,col,1];
                    fileName = cell2mat(filePaths(row+1,col,1));
                    badFileName = strcat(fileName(1:end-4),'BAD','.tif');
                    goodFileName = fileName;
                    display('Ignoring and replacing: ')
                    display(goodFileName);
                    dapiDown = uint16(dapiDown);
                    tiffToFile(badImg,badFileName);
                    tiffToFile(dapiDown,goodFileName);
                end
                dapiDownOld = dapiDown;
                %----------------------------------------------------------
                %Crop the images to get rid of the overlap
                if (row+1) ~= Hs.rows %If not on bottom
                    dapiDown = dapiDown(1:(size(dapiDown,1) - Hs.overlap),:);
                end
                if (col) ~= Hs.cols %If not on right side
                    dapiDown = dapiDown(:,1:(size(dapiDown,2) - Hs.overlap));
                end
            end
            %--------------------------------------------------------------
            % DOWN-RIGHT IMAGE
            %--------------------------------------------------------------  
            if row ~= Hs.rows && col ~= Hs.cols
                dapiDownRight = imread(cell2mat(filePaths(row+1,col+1,1)));
                %----------------------------------------------------------
                % If not the the same as the other images then need to
                % substitute in another image
                if ~(row == 1 && col == 1) && ~isequal(size(dapiDownRight),Hs.imageSize)
                    badImg = dapiDownRight;
                    
                    dapiDownRight = dapiDownRightOld;
                    deletable = [deletable,row+1,col+1,1];
                    fileName = cell2mat(filePaths(row+1,col+1,1));
                    badFileName = strcat(fileName(1:end-4),'BAD','.tif');
                    goodFileName = fileName;
                    display('Ignoring and replacing: ')
                    display(goodFileName);
                    dapiDownRight = uint16(dapiDownRight);
                    tiffToFile(badImg,badFileName);
                    tiffToFile(dapiDownRight,goodFileName);
                end
                dapiDownRightOld = dapiDownRight;
                %----------------------------------------------------------
                %Crop the images to get rid of the overlap
                if (row+1) ~= Hs.rows %If not on bottom
                    dapiDownRight = dapiDownRight(1:(size(dapiDownRight,1) - Hs.overlap),:);
                end
                if (col+1) ~= Hs.cols %If not on right side
                    dapiDownRight = dapiDownRight(:,1:(size(dapiDownRight,2) - Hs.overlap));
                end
            end
            %--------------------------------------------------------------
            % Crop and Concatenate Images
            %-------------------------------------------------------------- 
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Extract method
            
            if row ~= Hs.rows && col ~= Hs.cols %Then concatenate all four
                dapiRightPiece = dapiRight(:,1:(size(dapiRight,2)/2));
                dapiDownPiece = dapiDown(1:(size(dapiDown,1)/2),:);
                dapiDownRightPiece = dapiDownRight(1:(size(dapiDownRight,1)/2),1:(size(dapiDownRight,2)/2));
                dapiCat = [dapiCurrent,dapiRightPiece;dapiDownPiece,dapiDownRightPiece];
            elseif row ~= Hs.rows %Then concatenate current and down
                dapiDownPiece = dapiDown(1:(size(dapiDown,1)/2),:);
                dapiCat = [dapiCurrent;dapiDownPiece];
            elseif col ~= Hs.cols %Then concatenate current and right piece
                dapiRightPiece = dapiRight(:,1:(size(dapiRight,2)/2));
                dapiCat = [dapiCurrent,dapiRightPiece];
            else
                dapiCat = dapiCurrent;
            end
            %--------------------------------------------------------------
            % Processing
            %--------------------------------------------------------------
            % The first input argument, "chanCurrents" contains all the
            % channel images.  tileSpots will be an array of cells each
            % containing a separate spots array
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Super complex function signature. Should switch to a
            % class/object strategy method if necessary to have so many
            % inputs & outputs.
            % Surprising aspects of this function:
            % - takes in dapiCat but not concatenated versions of FISH
            % channels,
            % - takes in row, cols, Hs.row, Hs.cols even though it is
            % presumably about processing a "SingleTile"
            % - Why is it "DensitySingleTile3"? Rename to
            % "DensitySingleTile"
            % - Why does it need to be given the Hs.imagesize. Shouldn't it
            % be able to calculate it from the images?
            % - Need a more descriptive name for some output variables:
            % what is the difference between tileSpots and tileSpotVals
            % what is a "Val"?
            %
            % This function would best return two objects/structs: one with
            % the nuclei, the other with spots, which could also have the
            % threshold in it.
            
            [tileNuclei,tileSpots, tileSpotVals,tileThresh,tileCentroids] = DensitySingleTile3(chanCurrents,dapiCat,row,col,Hs.rows,Hs.cols,Hs.overlap,Hs.imageSize);
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Extract method for appending to the table of spots.
            
            for index = 1:numel(chanSpots)
                chanSpots(index) = mat2cell([cell2mat(chanSpots(index));cell2mat(tileSpots(index))]);
                
                oldTable = cell2mat(chanSpotVals(index));
                addTable = cell2mat(tileSpotVals(index));
                if ~isempty(oldTable)
                    oldTable(ismember(oldTable(:,1),addTable(:,1)),2) = oldTable(ismember(oldTable(:,1),addTable(:,1)),2) + addTable(ismember(addTable(:,1),oldTable(:,1)),2);
                    addSubSet = addTable(~ismember(addTable(:,1),oldTable(:,1)),1:2);
                    newTable = [oldTable;addSubSet];
                else
                    newTable = addTable;
                end
                chanSpotVals(index) = mat2cell(newTable);     
                chanThresh(index) = mat2cell([cell2mat(chanThresh(index));cell2mat(tileThresh(index))]);
            end
            % Tile centroids are not assigned until outside this loop, once
            % the "too-close" duplicate nuclei are discarded
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Rename tileCenInds : avoid abbreviation and make it
            % clear that it contains Centroid positions for *all* tiles.
            
            tileCenInds(row,col) = mat2cell([size(centroids,1)+1,size(centroids,1)+size(tileCentroids,1)]);
            nuclei = [nuclei,tileNuclei];
            centroids = [centroids;tileCentroids];
            %--------------------------------------------------------------
            index = index + 1;
        end
    end

    %----------------------------------------------------------------------
    % Sort each matrix contained in the cells of chanSpotVals
    %----------------------------------------------------------------------
    if ~ishandle(Hs.waitbarH)
        Hs.waitbarH = waitbar(0,'Sorting data structures');
    else
        waitbar(0,Hs.waitbarH,'Sorting data structures')
    end
    chanSpotValsTemp = [];
    for spotVals = chanSpotVals
        spotVals = cell2mat(spotVals);
        %Sort rows based on first column
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: What is the first column? Should make spotVals into a
        % smarter object or a struct so we can call it by name.
        
        spotVals = mat2cell(sortrows(spotVals,1));
        chanSpotValsTemp = [chanSpotValsTemp,spotVals];
    end
    chanSpotVals = chanSpotValsTemp;
    
    
    %======================================================================
    %----------------------------------------------------------------------
    if ~ishandle(Hs.waitbarH)
        Hs.waitbarH = waitbar(1,'Generating threshold values');
    else
        waitbar(1,Hs.waitbarH,'Generating threshold values');
    end
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Does the following block actually generate threshold values?
    % In what sense? 
    % Also, extract method.
    
    % The second column corresponds to the number of spots that will be
    % displayed at the threshold in the left column.  As of now, the right
    % column only contains how many spots correspond to that specific
    % threshold in the left column.  So, all values including and below the
    % value of the right column need to be summed
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: These columns should have names, so that an extensive comment
    % is not needed.
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Rename: "Temp" -> "Sorted"
    chanSpotValsTemp = [];
    for chanIndex = 1:numel(chanSpotVals)
        table2 = [];
        table = cell2mat(chanSpotVals(chanIndex));

        table2 = zeros(size(table,1),1);
        table2(:,1) = table(:,1);
        col2 = table(:,2);
        col2 = flipud(cumsum(flipud(col2)));
        
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % $$$ GN: Delete!
        
%         size(col2)
%         display(table(end,1));
%         for r = 1:size(table,1)
%             if mod(r,2000) == 0
%                 progress = (((chanIndex - 1) * size(table,1)) + r)/(numel(chanSpotVals) * size(table,1));
%                 if ~ishandle(Hs.waitbarH)
%                     Hs.waitbarH = waitbar(progress,'Sorting data structures');
%                 else
%                     waitbar(progress,Hs.waitbarH,'Sorting data structures')
%                 end
%             end
%             table2(r,2) = sum(table(r:end,2));
%         end
%         table2 = table2(:,1:2);
        table2 = [table2,col2];
                
        chanSpotValsTemp = [chanSpotValsTemp,mat2cell(table2)];

    end
    chanSpotVals = chanSpotValsTemp;
    %----------------------------------------------------------------------
    %======================================================================
    
    %----------------------------------------------------------------------
    % Find all centroids within a certain distance of each other and delete
    % all but one of these
    %----------------------------------------------------------------------
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Extract method.
    Hs.centroids = centroids;
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Deleting duplicate nuclei?
    
    if ~ishandle(Hs.waitbarH)
        Hs.waitbarH = waitbar(1,'Deleting duplicate values');
    else
        waitbar(1,Hs.waitbarH,'Deleting duplicate values');
    end
    % For each tile, compare the distances between the centroids of this
    % tile, the tile on the right, the tile down-right and the tile down
    deleteInds = [];
    for row = 1:Hs.rows
        for col = 1:Hs.cols
            
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: Refactor this whole block by extracting methods with
            % meaningful names. Currently, impenetrable. 
            
            currB = cell2mat(tileCenInds(row,col));
            currCent = Hs.centroids(currB(1):currB(2),:);
            currIndMap = (currB(1):currB(2))';
            rightCent = [];
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: MATLAB IDE thinks no one uses this.
            rightCentMap = [];
            rightIndMap = [];
            if col+1 <= Hs.cols
                rightB = cell2mat(tileCenInds(row,col+1));
                rightCent = Hs.centroids(rightB(1):rightB(2),:);
                rightIndMap = (rightB(1):rightB(2))';
            end
            downCent = [];
            downCentMap = [];
            downIndMap = [];
            if row + 1 <= Hs.rows
                downB = cell2mat(tileCenInds(row+1,col));
                downCent = Hs.centroids(downB(1):downB(2),:);
                downIndMap = (downB(1):downB(2))';
            end
            downRightCent = [];
            downRightCentMap = [];
            downRightIndMap = [];
            if row+1 <= Hs.rows && col+1 <= Hs.cols
                downRightB = cell2mat(tileCenInds(row+1,col+1));
                downRightCent = Hs.centroids(downRightB(1):downRightB(2),:);
                downRightIndMap = (downRightB(1):downRightB(2))';
            end
            if size(rightCent) > 0
                
                % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                % $$$ GN: This block is copy-pasted no less than three
                % times!! Extract method!!
                
                centroids = [currCent;rightCent];
                indexMap = [currIndMap;rightIndMap];
                dist = pdist(centroids);
                dist = squareform(dist);
                %Set diagonal to 10 (currently 0) so not detected as being less than 5
                [nRows,nCols] = size(dist);
                dist(1:(nRows+1):nRows*nCols) = 10;
                %Get all pairs less than 5 pixels appart
                [r,c] = ind2sub(size(dist),find(dist < 5));
                inds = [r,c];
                if size(inds,1) > 0
                    %Sort each row in ascending order - this is to ensure we only delete one of the elements. 
                    inds = sort(inds,2);
                    inds = inds(:,1);
                    deletes = indexMap(inds);
                    %Delete all rows of Hs.centroids that are contained in the first column 
                    %of map
                    deleteInds = [deleteInds;deletes];
                end
            end
            if size(downCent) > 0
                centroids = [currCent;downCent];
                indexMap = [currIndMap;rightIndMap];
                dist = pdist(centroids);
                dist = squareform(dist);
                %Set diagonal to 10 (currently 0) so not detected as being less than 5
                [nRows,nCols] = size(dist);
                dist(1:(nRows+1):nRows*nCols) = 10;
                %Get all pairs less than 5 pixels appart
                [r,c] = ind2sub(size(dist),find(dist < 5));
                inds = [r,c];
                if size(inds,1) > 0
                    %Sort each row in ascending order - this is to ensure we only delete one of the elements. 
                    inds = sort(inds,2);
                    inds = inds(:,1);
                    deletes = indexMap(inds);
                    %Delete all rows of Hs.centroids that are contained in the first column 
                    %of map
                    deleteInds = [deleteInds;deletes];
                end   
            end
            if size(downRightCent) > 0
                centroids = [currCent;downRightCent];
                indexMap = [currIndMap;downRightIndMap];
                dist = pdist(centroids);
                dist = squareform(dist);
                %Set diagonal to 10 (currently 0) so not detected as being less than 5
                [nRows,nCols] = size(dist);
                dist(1:(nRows+1):nRows*nCols) = 10;
                %Get all pairs less than 5 pixels appart
                [r,c] = ind2sub(size(dist),find(dist < 5));
                inds = [r,c];
                if size(inds,1) > 0
                    %Sort each row in ascending order - this is to ensure we only delete one of the elements. 
                    inds = sort(inds,2);
                    inds = inds(:,1);
                    deletes = indexMap(inds);
                    %Delete all rows of Hs.centroids that are contained in the first column 
                    %of map
                    deleteInds = [deleteInds;deletes];
                end
            end
        end
    end
    Hs.centroids(deleteInds(:,1),:) = [];
    nuclei(:,deleteInds(:,1)) = [];

    
    %----------------------------------------------------------------------
    % Delete all spots and centroids that are from inserted tiles (tiles
    % that were inserted since original tile was too small)
    %----------------------------------------------------------------------
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Extract method!
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: Is it not possible to just *not* process bad tiles? Just
    % assign no centroids or spots to them, instead of redoing a previous
    % tile and then deleting everything?
    
    for indexRow = 1:size(deletable,1)
        lowerRow = (Hs.imageSize(1) - Hs.overlap) * (deletable(indexRow,1) - 1);
        upperRow = lowerRow + (Hs.imageSize(1) - Hs.overlap);
        lowerCol = (Hs.imageSize(2) - Hs.overlap) * (deletable(indexRow,2) - 1);
        upperCol = lowerCol + (Hs.imageSize(2) - Hs.overlap);
        if deletable(indexRow,3) == 1 %Delete centroids
            % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % $$$ GN: What is this scenario? Looks like you are deleting
            % stuff in the else too. If this is a general deleter, could
            % use such a method/function. As it is, I see no mention
            % specifically of the inserted tile problem.
            
            % Delete contained centroids
            deleteRows = lowerRow <= Hs.centroids(:,1) & Hs.centroids(:,1) <= upperRow & lowerCol <= Hs.centroids(:,2) & Hs.centroids(:,2) <= upperCol;
            Hs.centroids(deleteRows,:) = [];
        else
            spots = cell2mat(chanSpots(deletable(indexRow,3) - 1));
            deleteRows = lowerRow <= spots(:,1) & spots(:,1) <= upperRow & lowerCol <= spots(:,2) & spots(:,2) <= upperCol;
            spots(deleteRows,:) = [];
            %Delete contained spots
            chanSpots(deletable(indexRow,3) - 1) = mat2cell(spots);
        end
    end
    
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % $$$ GN: We should really move to an OO approach.
    
    Hs.filePaths = filePaths;
    Hs.chanSpots = chanSpots;
    Hs.nuclei = nuclei;
    Hs.chanThresh = chanThresh;
    Hs.imageSize = Hs.imageSize;
    Hs.chanSpotVals = chanSpotVals;
    Hs.deletable = deletable;
end

function radioButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    str = get(eventData.NewValue,'String');
    if strcmp(str,'RNA Map')
        Hs.radioVal = 1;
    else
        Hs.radioVal = 2;
    end
    Hs = plotImage(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when "reset" button clicked
%--------------------------------------------------------------------------
function resetButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    answer = questdlg('Proceeding will reset all deletions from this and previous sessions.  Are you sure you want to continue?','Warning','Yes','No','No');
    if ~strcmp('Yes',answer)
         return;
    end
    Hs.chanDeleted = cell(1,numel(Hs.chanDeleted));
    Hs.centDeleted = [];
    %------------------------------------------------------------------
    % Create the corresponding spot maps for each channel
    % Hs.chanSpotMaps   n cells (n is # of channels) with each matrix:
    %                   [centroidIndex] with each row corresponding to the
    %                   index of its associated centroid
    %------------------------------------------------------------------
    centroidSubSet = Hs.centroids;
    waitH = waitbar(0,'Resetting chan spot maps');
    Hs.chanSpotMaps = cell(size(Hs.chanSpots));
    for index = 1:numel(Hs.chanSpots)
        if ishandle(waitH)
            waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Resetting chan spot maps');
        else
            waitH = waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Resetting chan spot maps');
        end
        
        spots = cell2mat(Hs.chanSpots(index));
        spotMap = knnsearch(centroidSubSet,spots(:,1:2));
        Hs.chanSpotMaps(index) = mat2cell(spotMap);
    end
    if ishandle(waitH)
        waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Activating spots and maps');
    else
        waitH = waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Activating spots and maps');
    end
    Hs = activateSpotsAndCentroidMap(Hs);
    Hs = plotImage(Hs);
    %------------------------------------------------------------------
    % Save the data
    %------------------------------------------------------------------
    if ishandle(waitH)
        waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Saving the data');
    else
        waitH = waitbar((index - 1)/numel(Hs.chanSpots),waitH,'Saving the data');
    end
    TEMP = load(Hs.fileName);
    TEMP.chanDeleted = Hs.chanDeleted;
    TEMP.centDeleted = Hs.centDeleted;
    save(Hs.fileName,'-struct', 'TEMP','chanThresh','chanThreshVal','foundChannels','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','chanDeleted','centDeleted');
    guidata(gcbo,Hs);
    delete(waitH);
end

%--------------------------------------------------------------------------
% Called Hs.resetThresh pushbutton is clicked
%--------------------------------------------------------------------------
function resetThreshold_Callback(hObject, eventdata)
    Hs = guidata(gcbo);
    % Determine what threshold and threshold min should be.  Needed for
    % plotThreshAx.  Hs.chanThresh(N) is a cell for the Nth channel
    % containing the auto-threshold values for each tile
    threshes = cell2mat(Hs.chanThresh(Hs.chanIndex));
    Hs.threshold = median(double(threshes));
    Hs.thresholdMin = min(threshes/2);
    Hs.chanThreshVal(Hs.chanIndex,1) = Hs.threshold;
    Hs.chanThreshVal(Hs.chanIndex,2) = Hs.thresholdMin;
    
    Hs = plotThreshAx(Hs);
    % Get Hs.centroidMap, Hs.spotMap, and Hs.spotMax
    Hs = activateSpotsAndCentroidMap(Hs);
    % Updates the image that is being displayed
    Hs = plotImage(Hs);
    
    setFocusToFigure(Hs);
    guidata(gcbo,Hs);
    % Populate centroid list box. Hs.centSort contains the sorted 
    % descending order of centroid-spots
    Hs = populateCentroidBox(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when "Save" button selected
%--------------------------------------------------------------------------
function saveCentroidMapsCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    
    Td.centroidMaps = getCentroidMaps(Hs);
    
    waitH = waitbar(0,'Creating image mapping');
    centroidSubSet = Hs.centroids;
    centroidSubSet(Hs.centDeleted,:) = [];
    Td.centroidLocs = cell(size(centroidSubSet,1),1);
    overlapR = Hs.overlap;
    for index = 1:(size(centroidSubSet,1))
        if ~ishandle(waitH)
            waitH = waitbar(index/size(centroidSubSet,1),'Creating image mapping');
        else
            waitbar(index/size(centroidSubSet,1),waitH,'Creating image mapping');
        end
        row = round(centroidSubSet(index,1));
        col = round(centroidSubSet(index,2));
        
        imgRowWidth = Hs.imageSize(1,1);
        tileRow = floor((row - 1) / (imgRowWidth - overlapR)) + 1;
        % Necessary since size of border images is not imgRowWidth -
        % overlapR but instead imgRowWidth
        if tileRow > Hs.rows
            tileRow = Hs.rows;
        end
        imgColWidth = Hs.imageSize(1,2);
        tileCol = floor((col - 1) / (imgColWidth - overlapR)) + 1;
        % Necessary since size of border images is not imgColWidth -
        % overlapR but instead imgColWidth
        if tileCol > Hs.cols
            tileCol = Hs.cols;
        end

        Td.centroidLocs(index,1) = Hs.filePaths(tileRow,tileCol,1);
    end
    Td.foundChannels = [];
    
    
    for index = 1:numel(Hs.foundChannels)
        channel = cell2mat(Hs.foundChannels(index));
        if ~strcmp(channel,'dapi')
            Td.foundChannels = [Td.foundChannels,mat2cell(channel)];
        end
    end
    
    if ~ishandle(waitH)
        waitH = waitbar(1,'Saving files');
    else
        waitbar(1,waitH,'Saving files');
    end
    save('CentroidMaps','-struct', 'Td','centroidMaps','foundChannels','centroidLocs');
    save(Hs.fileName,'-struct', 'Hs','centRGBMaps','foundChannels','chanThreshVal','chanThresh','chanSpots','chanSpotMaps','imageSize','centroids','chanSpotVals','overlap','chanMaps','layoutIndex','rows','cols','chanDeleted','centDeleted');
    if ishandle(waitH)
        delete(waitH);
    end
end

%--------------------------------------------------------------------------
% WARNING!!!!  JAVAFRAME WILL BE DEPRECATED SOON!?!?! Who knows when but
% this is the only viable option to return focus to the main figure after
% using one of the uicontrol objects.
%--------------------------------------------------------------------------
function Hs = setFocusToFigure(Hs)
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    javaFrame = get(Hs.figH,'JavaFrame');
    javaFrame.getAxisComponent.requestFocus;
end

%--------------------------------------------------------------------------
% Turns the children in the draw-panel to on (1) or off (0).  Called by
% zoomButtonCallBack, dragButtonCallBack, and drawButtonCallBack
%--------------------------------------------------------------------------
function setDrawPanelState(Hs, value)
    childrenH = get(Hs.drawPanel,'Children');
    for handle = childrenH
        if value == 1
            set(handle,'Enable','on');
        elseif value == 0
            set(handle,'Enable','off');
            % Delete all imfreehand handles
            if isfield(Hs,'freeHandsH')
                for hand = Hs.freeHandsH
                    delete(hand);
                end
            end
        end
        
    end  
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Uses the current Hs.row_zoom and Hs.col_zoom as well as center (which is
% [row,col] of click to determine where the upper-left index (Hs.ulIndex) 
% of the "zoom-box" should be.
% Called by: 
% - thumbAxisButtonDown, buttonMoveThumbAxis, 
% - buttonMove, listBoxCallBack,
% - fitToZoomBox, zoomClick_Callback
%--------------------------------------------------------------------------
function Hs = setULIndex(Hs,center)
    if (center(1,2) - Hs.row_zoom/2) >= 0 && (center(1,2) + Hs.row_zoom/2) <= Hs.row_width
        Hs.ulIndex(1,1) = round(center(1,2)) - Hs.row_zoom/2;
    elseif (center(1,2) - (Hs.row_zoom/2)) < 0
        Hs.ulIndex(1,1) = 1;
    else
        Hs.ulIndex(1,1) = Hs.row_width - Hs.row_zoom;
    end

    if center(1,1) - Hs.col_zoom/2 >= 0 && center(1,1) + Hs.col_zoom/2 <= Hs.col_width
        Hs.ulIndex(1,2) = round(center(1,1)) - Hs.col_zoom/2;
    elseif center(1,1) - Hs.col_zoom/2 < 0
        Hs.ulIndex(1,2) = 1;
    else
        Hs.ulIndex(1,2) = Hs.col_width - Hs.col_zoom;
    end
end

%--------------------------------------------------------------------------
% Called when any of shift-buttons clicked
%--------------------------------------------------------------------------
function shiftButtonCallBack(hObject, eventData, type)
    Hs = guidata(gcbo);
    shiftAmount = (Hs.threshXLim + Hs.chanThreshShifts(Hs.chanIndex))/10;
    if type == -1 %shift left
        Hs.chanThreshShifts(Hs.chanIndex) = round(Hs.chanThreshShifts(Hs.chanIndex) - shiftAmount);
    elseif type == 1 %shift right
        Hs.chanThreshShifts(Hs.chanIndex) = round(Hs.chanThreshShifts(Hs.chanIndex) + shiftAmount);
    elseif type == 0 %Reset shift
        Hs.chanThreshShifts(Hs.chanIndex) = 0;
    end
    if Hs.threshXLim + Hs.chanThreshShifts(Hs.chanIndex) <= Hs.threshold
        Hs.chanThreshShifts(Hs.chanIndex) = Hs.threshold - Hs.threshXLim;
    end
    Hs = plotThreshAx(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when 'Spot Numbers' checkbox is clicked
%--------------------------------------------------------------------------
function spotNCheckCallBack(hObject,eventdata)
    if (get(hObject,'Value') == get(hObject,'Max'))%checked
        Hs = guidata(gcbo);
        Hs.repaintN = true;
        if ~isfield(Hs,'centNumH')
            for p = Hs.centNumH
                if ishandle(p)
                    delete(p);
                end
            end
        end
        Hs = plotNumsAndCircs(Hs);
        guidata(gcbo,Hs);
    else %unchecked
        Hs = guidata(gcbo);
        if isfield(Hs,'centNumH')
            for p = Hs.centNumH
                if ishandle(p)
                    delete(p);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------
% Called when 'Circles' checkbox is clicked
%--------------------------------------------------------------------------
function spotCCheckCallBack(hObject,eventdata)
    %----------------------------------------------------------------------
    % Delete any spot-circles or scatter-plots
    Hs = guidata(gcbo);
    if isfield(Hs,'spotCircsH')
        for p = Hs.spotCircsH
            if ishandle(p)
                delete(p);
            end
        end
    end
    if isfield(Hs,'scatterH') && ishandle(Hs.scatterH)
        delete(Hs.scatterH);
    end
    %----------------------------------------------------------------------
    %If button is checked, call plotNumsAndCircs
    if (get(hObject,'Value') == get(hObject,'Max'))%checked
        Hs.repaintC = true;
        Hs = plotNumsAndCircs(Hs);
    end
    %Reload figure data
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when there is a click in the Hs.thumbAx axis.  Since
% thumb-rectangle needs to be draggable, motion function is attached and
% Hs.downState is set to 'thumbAxis'.  Button release will be detected by
% buttonUpCallBack (which is figure's WindowButtonUpFcn) so Hs.downState is
% needed to determine the region of the click
%--------------------------------------------------------------------------
function thumbAxisButtonDown(hObject, eventdata)
    Hs = guidata(gcbo);
    Hs.downState = 'thumbAxis';
    center = get(Hs.thumbAx,'CurrentPoint');    
    Hs = setULIndex(Hs,center);
    Hs = plotImage(Hs);
    set(Hs.hObject,'WindowButtonMotionFcn',@buttonMoveThumbAxis);
    guidata(Hs.figH,Hs);
end

function tiffToFile(img,fileName)

    try
    t = Tiff(fileName,'w');
    % http://www.mathworks.com/help/matlab/import_export/exporting-to-images.html
    tags.ImageLength   = size(img,1);
    tags.ImageWidth    = size(img,2);
    tags.Photometric   = Tiff.Photometric.MinIsBlack;
    tags.BitsPerSample = 16;
    tags.SampleFormat  = 1; %Uint
    tags.RowsPerStrip  = 16;
    tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tags.SamplesPerPixel = 1;

    t.setTag(tags);
    t.write(img);
    catch
        display(fileName);
    end
end

%--------------------------------------------------------------------------
% Called when Hs.threshAx axis is clicked.  Figures out the x-axis
% coordinate and sets the threshold to that value as long as the value is
% above Hs.thresholdMin
%--------------------------------------------------------------------------
function thresholdClick_Callback(hObject,eventdata)
    Hs = guidata(gcbo);
    position = get(hObject,'CurrentPoint');
    if position(1,1) > Hs.thresholdMin
        Hs.threshold = position(1,1);
    else
        Hs.threshold = Hs.thresholdMin;
    end
    Hs.chanThreshVal(Hs.chanIndex,1) = Hs.threshold;
    
    Hs = plotThreshAx(Hs);
    % Get Hs.centroidMap, Hs.spotMap, and Hs.spotMax
    Hs = activateSpotsAndCentroidMap(Hs);
    Hs = plotImage(Hs);
    
    % Populate centroid list box. Hs.centSort contains the sorted 
    % descending order of centroid-spots
    Hs = populateCentroidBox(Hs);
    setFocusToFigure(Hs);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when "undo" button clicked
%--------------------------------------------------------------------------
function undoButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    if numel(Hs.freeHandsH) >= 1
        garbage = Hs.freeHandsH(end);
        Hs.freeHandsH = Hs.freeHandsH(1,1:(end-1));
        delete(garbage);
    end
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% Called when "view" button clicked
%--------------------------------------------------------------------------
function viewButtonCallBack(hObject, eventData)
    Hs = guidata(gcbo);
    
    center(1,1) = Hs.ulIndex(1) + (Hs.row_zoom / 2);
    center(1,2) = Hs.ulIndex(2) + (Hs.col_zoom / 2);
    
    %Find which tile the center is in
    tileRow = floor(center(1,1) / (Hs.imageSize(1,1) - Hs.overlap)) + 1;
    if tileRow > Hs.rows
        tileRow = Hs.rows;
    end
    tileCol = floor(center(1,2) / (Hs.imageSize(1,2) - Hs.overlap)) + 1;
    if tileCol > Hs.cols
        tileCol = Hs.cols;
    end
    left = [];leftUp = []; up = []; rightUp = []; right = []; rightDown = []; down = []; leftDown = [];
    
    upGood = tileRow - 1 >= 1;
    downGood = tileRow + 1 <= size(Hs.filePaths,1);
    leftGood = tileCol - 1 >= 1;
    rightGood = tileCol + 1 <= size(Hs.filePaths,2);

    current = imread(cell2mat(Hs.filePaths(tileRow,tileCol,Hs.chanIndex + 1)));
    if leftGood
        left = imread(cell2mat(Hs.filePaths(tileRow,tileCol - 1,Hs.chanIndex + 1)));
        left = left(1:end,1:(end - Hs.overlap));
    end
    if leftGood && upGood
        leftUp = imread(cell2mat(Hs.filePaths(tileRow-1,tileCol-1,Hs.chanIndex + 1)));
        leftUp = leftUp(1:(end - Hs.overlap),1:(end - Hs.overlap));
    end
    if upGood
        up = imread(cell2mat(Hs.filePaths(tileRow-1,tileCol,Hs.chanIndex+1)));
        up = up(1:(end - Hs.overlap),1:end);
    end
    if upGood && rightGood
        rightUp = imread(cell2mat(Hs.filePaths(tileRow-1,tileCol+1,Hs.chanIndex+1)));
        rightUp = rightUp(1:(end - Hs.overlap),1:end);
    end
    if rightGood
        right = imread(cell2mat(Hs.filePaths(tileRow,tileCol+1,Hs.chanIndex+1)));
    end
    if rightGood && downGood
        rightDown = imread(cell2mat(Hs.filePaths(tileRow+1,tileCol+1,Hs.chanIndex+1)));
    end
    if downGood
        down = imread(cell2mat(Hs.filePaths(tileRow+1,tileCol,Hs.chanIndex+1)));
    end
    if leftGood && downGood
        leftDown = imread(cell2mat(Hs.filePaths(tileRow+1,tileCol-1,Hs.chanIndex+1)));
        leftDown = leftDown(1:end,1:(end - Hs.overlap));
    end
    if tileCol + 1 < Hs.cols
        rightUp = rightUp(1:end,1:(end - Hs.overlap));
        right = right(1:end,1:(end - Hs.overlap));
        rightDown = rightDown(1:end,1:(end - Hs.overlap));
    end
    if tileCol < Hs.cols
        current = current(1:end,1:(end - Hs.overlap));
        up = up(1:end,1:(end - Hs.overlap));
        down = down(1:end,1:(end - Hs.overlap));
    end
    if tileRow + 1 < Hs.rows
        leftDown = leftDown(1:(end - Hs.overlap),1:end);
        down = down(1:(end - Hs.overlap),1:end);
        rightDown = rightDown(1:(end - Hs.overlap),1:end);
    end
    if tileRow < Hs.rows
        left = left(1:(end - Hs.overlap),1:end);
        current = current(1:(end - Hs.overlap),1:end);
        right = right(1:(end - Hs.overlap),1:end);
    end
    imgCat = [leftUp,up,rightUp;left,current,right;leftDown,down,rightDown];
    figure,imcontrast(imshow(imgCat));
end

%--------------------------------------------------------------------------
% Called when 'Zoom' toggle is clicked
%--------------------------------------------------------------------------
function zoomButtonCallBack (hObject,eventdata)
    Hs = guidata(gcbo);
    set(gcf,'Pointer','arrow')
    if get(Hs.dragButton,'Value') == 1
        set(Hs.dragButton,'Value',0);
    end
    if get(Hs.drawButton,'Value') == 1
        set(Hs.drawButton,'Value',0);
    end
    if isfield(Hs,'freeHandsH') & numel(Hs.freeHandsH) > 0
       for handle = Hs.freeHandsH
           delete(handle);
       end
       Hs.freeHandsH = [];
    end
    setDrawPanelState(Hs,0);
    guidata(gcbo,Hs);
end

%--------------------------------------------------------------------------
% %Called by buttonUpCallBack when click released on same point as pressed
%--------------------------------------------------------------------------
function zoomClick_Callback(hObject, eventdata)
    Hs = guidata(gcbo);    
    center = get(Hs.imgAx,'CurrentPoint');

    cmd = get(gcbf, 'SelectionType');
    factor = Hs.row_zoom/10;
    if strcmp(cmd,'normal')  %left-click --> zoom-in
        Hs.row_zoom = Hs.row_zoom - (2 * factor);
        if Hs.row_zoom < 20
            Hs.row_zoom = 20;
        end
        Hs.col_zoom = Hs.col_zoom - (2 * factor);
        if Hs.col_zoom < 20
            Hs.col_zoom = 20;
        end
        final_zoom = min(Hs.row_zoom,Hs.col_zoom);
        Hs.row_zoom = final_zoom;
        Hs.col_zoom = final_zoom;
    elseif strcmp(cmd,'alt') %right-click --> zoom-out
        Hs.row_zoom = Hs.row_zoom + (4 * factor);
        if Hs.row_zoom > Hs.row_width
            Hs.row_zoom = Hs.row_width;
        end
        Hs.col_zoom = Hs.col_zoom + (4 * factor);
        if Hs.col_zoom > Hs.col_width
            Hs.col_zoom = Hs.col_width;
        end
    elseif strcmp(cmd,'open')
        Hs.row_zoom = Hs.row_width;
        Hs.col_zoom = Hs.col_width;
        % Turn off spot numbers
        set(Hs.spotNCheck,'Value',0);
    end
    if strcmp(cmd,'normal') || strcmp(cmd,'alt')
        Hs = setULIndex(Hs,center);
        Hs = plotImage(Hs);
        set(Hs.imgAx,'NextPlot','replacechildren'); % needs to be set each time
        setFocusToFigure(Hs);
        guidata(gcbo,Hs);
    end
    if strcmp(cmd,'open')
        Hs.ulIndex = [0,0];
        Hs = plotImage(Hs);
        set(Hs.imgAx,'NextPlot','replacechildren'); % needs to be set each time
        setFocusToFigure(Hs);
        guidata(gcbo,Hs);
    end

end