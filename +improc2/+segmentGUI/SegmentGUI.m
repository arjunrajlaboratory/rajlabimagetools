%% SegmentGUI
% A graphical user interface to segment image objects (cells, embryos, nuclei, etc)

%% Description
% This program lets you select the cells or embryos for which you would like
% to count RNA spots.
%
% Press the "Segment" button or hit the 'option' key to use the freehand
% segmenting tool.
%
% Press the "Undo Segment" button or hit the 'delete' key to undo the last
% segmented object.
%
% Press the "Next File" button or hit the 'rightarrow' key to save and
% move on to the next file. "Prev File" ('left arrow') to save and go
% back in the file sequence.
%

%% MATLAB Figure file for GUI development
% There is a MATLAB figure file (SegmentGUILayout.fig) that is only used as 
% a way to place |uicontrol()| elements and use position properties field
% values to layout the GUI programmatically in this m-file.

%% Filename Enforcement
% Uniform file name schemes are used in the Raj lab for image stack files.
% Fluorescent channel images use short names followed by 3-digit number. 
% The used names are {'tmr','alexa','cy','gfp','nir'}
% DAPI (nuclear stain) and transmission images should follow the same
% numbering scheme.

%% Credits
% * Originally conceived by Arjun Raj
% * GUI-fied by Yaanik Desai
% * Rewritten by Marshall J. Levesque 2012

function varargout = SegmentGUI(varargin)

    if ~isempty(varargin)
        fileToStart = varargin{1};
    else
        fileToStart = 1;
    end

    %======================================================
    % Global variables are all stored in "Hs" structure,
    % aka "handles", the common place to store app data 
    % in a MATLAB GUI program. "Hs" makes for cleaner code
    % and "handles" doesn't apply to all the data types we
    % store in it.
    %======================================================

    figH = figure('Position',[200 100 806 567],...
                  'NumberTitle','off',...
                  'Name','SegmentGUI',...
                  'Resize','on',...
                  'Toolbar','none',...
                  'MenuBar','none',...
                  'Color',[0.247 0.247 0.247],...
                  'KeyPressFcn',@KeyPressCallback,...
                  'Visible','off');

    Hs = guihandles(figH);
    Hs.figH = figH;
    
    % Initialize some bookkeeping variables
    Hs.progressCount = 0;

    % Start by checking if we already have 'data***.mat' files
    % that store |image_object|. If so, we load the data files
    % to get images and the segmentation ROIs. 
    %---------------------------------------------------------
    Hs.dirPath = pwd;
    [Hs.dataFiles,Hs.dataNums] = getDataFiles(Hs.dirPath);

    % Look for image files in the current working directory. If we
    % don't find any, ask the user to navigate to the image files
    % using the GUI file browser. We check again for 'data***.mat'
    % and then the image files 
    %--------------------------------------------------------------
    [Hs.foundChannels,Hs.fileNums,Hs.imgExts] = getImageFiles(Hs.dirPath);
    if isempty(Hs.fileNums)  % no image files here
        fprintf(1,'Could not find any image files!\n');
        yn = input('Navigate to the directory with your files? y/n [y]','s');
        if isempty(yn); yn = 'y'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            Hs.dirPath = uigetdir(pwd,'Navigate to image files');
            if Hs.dirPath == 0;  % User pressed cancel 
                return;  % quit the GUI
            end
            [Hs.dataFiles,Hs.dataNums] = getDataFiles(Hs.dirPath);
            [Hs.foundChannels,Hs.fileNums,Hs.imgExts] = getImageFiles(Hs.dirPath);
            if isempty(Hs.fileNums)
                error('Could not find image files (eg ''tmr001.tif'' etc) to segment');
            end
        else
            return;  % user did not want to navigate to image files, quit GUI
        end
    end
    
    % make sure that if we have both data & image files, that the numbering
    % scheme makes some sense. For example, if we have 'data001-data010.mat'
    % files then there should also be 'tmr001-tmr010.tif' and not less.
    %------------------------------------------------------------------------
    if numel(Hs.dataFiles) > numel(Hs.fileNums)
        msg = sprintf(['There are more data*.mat files than image files\n'...
                       'This should not happen']);
        error(msg);
    end
    
    % remove dapi & trans from Hs.foundChannels and imgExts to get the 
    % RNA channels only
    Hs.RNAchannels = Hs.foundChannels;
    Hs.RNAchannels(strcmp('dapi',Hs.RNAchannels)) = [];
    Hs.RNAchannels(strcmp('trans',Hs.RNAchannels)) = [];
    Hs.RNAchannels = [Hs.RNAchannels 'NONE'];  % this selection hides RNA
    Hs.RNAchannel = Hs.RNAchannels{1};  % use the first RNA channel str to start
    
    set(figH,'Visible','on');
    Hs = buildGUI(Hs,figH);
    
    %start at first or user-specified RNA file
    if fileToStart > length(Hs.fileNums)
        Hs.fileNum = Hs.fileNums(end);
    else
        Hs.fileNum = Hs.fileNums(fileToStart); 
    end
    
    Hs = loadFileSet(Hs);
    
    % Update handles structure
    %--------------------------
    guidata(figH, Hs);

    return;
    %============================================================
    % End of the main SegmentGUI function. Everything else happens
    % passing around the |Hs| structure between functions
    %============================================================
        

function CloseRequest(hObject,eventdata)
    Hs = guidata(gcbo);
    setappdata(0,'Success',true);
    guidata(gcbo,Hs);
    uiresume(hObject);
    delete(hObject);


function Hs = loadFileSet(Hs)
    % Check for data files, get the objects & segmentation boundaries
    %-----------------------------------------------------------------
    Hs.allMasks = [];
    dataInd = find(Hs.fileNum == Hs.dataNums);  % matches data00N w/ tmr00N only
    if isempty(dataInd) 
        Hs.currObjs = [];
    else 
        Hs.currObjs = load([Hs.dirPath filesep Hs.dataFiles(dataInd).name]);
        Hs.currObjs = Hs.currObjs.objects;
        for obj = Hs.currObjs
            assert(isa(obj, 'improc2.dataNodes.GraphBasedImageObject'), ...
                'Convert the already-segmented objects in this directory to Graph Based Image Objects first.');
            if isempty(Hs.allMasks)  % first object
                Hs.allMasks = obj.object_mask.imfilemask;
            else
                Hs.allMasks = cat(3,Hs.allMasks,obj.object_mask.imfilemask);
            end
        end
    end

    % Get max-merges of the stacks and display the image 
    Hs = getMaxes(Hs,true);
    Hs.imgH = [];
    Hs = makeAndShowOverlay(Hs);
    Hs = updateDisplay(Hs);


function Hs = makeAndShowOverlay(Hs)
    % make a composite of the dye channel, dapi, and trans.
    Hs.RGB = zeros([size(Hs.RI) 3],class(Hs.RI));
    if ~strcmp(Hs.RNAchannel,'NONE')
        if ~get(Hs.checkboxContrast,'Value')
            Hs.RGB(:,:,1)  = Hs.RGB(:,:,1) + Hs.RI2;
            Hs.RGB(:,:,2)  = Hs.RGB(:,:,2) + Hs.RI2;
            set(Hs.contrastMaxVal,'String',num2str(max(Hs.RI2(:))));
        else
            RI2 = Hs.RI2;
            mx = str2num(get(Hs.contrastMaxVal,'String'));
            mn = min(RI2(:));
            RI2 = (RI2-mn)/(mx-mn);
            RI2(RI2>1) = 1;
            Hs.RGB(:,:,1)  = Hs.RGB(:,:,1) + RI2;
            Hs.RGB(:,:,2)  = Hs.RGB(:,:,2) + RI2;

        end;        
    end
    if get(Hs.dapiCheck,'Value') == get(Hs.dapiCheck,'Max')
        halfDAPI = Hs.DI/2;
        clip = Hs.RGB(:,:,2) + halfDAPI;
        clip(clip>1) = 1; Hs.RGB(:,:,2) = clip;
        clip = Hs.RGB(:,:,3) + halfDAPI;
        clip(clip>1) = 1; Hs.RGB(:,:,3) = clip;
    end
    if get(Hs.transCheck,'Value') == get(Hs.transCheck,'Max')
        halfTrans = Hs.TI/2;
        clip = Hs.RGB(:,:,1) + halfTrans;
        clip(clip>1) = 1; Hs.RGB(:,:,1) = clip;
        clip = Hs.RGB(:,:,2) + halfTrans;
        clip(clip>1) = 1; Hs.RGB(:,:,2) = clip;
        clip = Hs.RGB(:,:,3) + halfTrans;
        clip(clip>1) = 1; Hs.RGB(:,:,3) = clip;
    end

    if ~isempty(Hs.allMasks)
        % Use image field sized BW image made up of all segmented ROIs to 
        % build the composite RGB where object masks are labeled in blue
        % with a black outline.
        maskTotal = logical(sum(Hs.allMasks,3));
        tmpImg = Hs.RGB(:,:,3);
        tmpImg(maskTotal) = 1;
        Hs.RGB(:,:,3) = tmpImg; % blue is maxed out
        bwp = bwperim(maskTotal); 
        tmpImg = Hs.RGB(:,:,1); tmpImg(bwp) = 0; Hs.RGB(:,:,1) = tmpImg;
        tmpImg = Hs.RGB(:,:,2); tmpImg(bwp) = 0; Hs.RGB(:,:,2) = tmpImg;
        tmpImg = Hs.RGB(:,:,3); tmpImg(bwp) = 0; Hs.RGB(:,:,3) = tmpImg;
    end

    %-------------------------------------
    % done with setup, now show the image 
    %-------------------------------------
    if isempty(Hs.imgH)
        Hs.imgH = imshow(Hs.RGB,'Parent',Hs.imgAx);
    else
        set(Hs.imgH,'CDATA',Hs.RGB);
    end
    

function Hs = getMaxes(Hs,updateAllImgs)
% RNA and DAPI images max merges are a sampling of the image stack planes
% trans is the 3rd plane in the stack
    
    currInd = strcmp(Hs.RNAchannel,Hs.foundChannels);
    if ~strcmp(Hs.RNAchannel,'NONE')
        Hs.RI = readmm(sprintf('%s%s%s%03d%s',...
                   Hs.dirPath,filesep,Hs.RNAchannel,Hs.fileNum,Hs.imgExts{currInd}));
        Hs.RI = Hs.RI.imagedata; 
        Hs.RI = scale(max(Hs.RI(:,:,round(linspace(3,size(Hs.RI,3),10))),[],3));
        Hs.RI2 = scale(medfilt2(Hs.RI));
    end

    if updateAllImgs
        sz = size(Hs.RI);
        ty = class(Hs.RI);
        tF = find(strcmpi('trans',Hs.foundChannels));
        if isempty(tF)
            Hs.TI = zeros(sz,ty);
            set(Hs.transCheck,'Enable','off','Value',0);
        else
            Hs.TI = readmm(sprintf('%s%s%s%03d%s',Hs.dirPath,filesep,...
                            Hs.foundChannels{tF},Hs.fileNum,Hs.imgExts{tF}),3);
            Hs.TI = scale(Hs.TI.imagedata);
            set(Hs.transCheck,'Enable','on');
        end

        dF = find(strcmpi('dapi',Hs.foundChannels));
        if isempty(dF)
            Hs.DI = zeros(sz,ty);
            set(Hs.dapiCheck,'Enable','off','Value',0);
        else
            Hs.DI = readmm(sprintf('%s%s%s%03d%s',Hs.dirPath,filesep,...
                            Hs.foundChannels{dF},Hs.fileNum,Hs.imgExts{dF}));
            Hs.DI = Hs.DI.imagedata;
            Hs.DI = scale(max(Hs.DI(:,:,round(linspace(3,size(Hs.DI,3),4))),[],3));
            set(Hs.dapiCheck,'Enable','on');
        end
    end


function Hs = updateDisplay(Hs)
    fileInd = find(Hs.fileNum == Hs.fileNums);
    Hs.progressCount(fileInd) = numel(Hs.currObjs);
    set(Hs.fileProgress,'String',sprintf('%d / %d',fileInd,numel(Hs.fileNums)));
    set(Hs.numSaved,'String',sprintf('%d',sum(Hs.progressCount)));


%================================================
% * Callback functions for |uicontrol()| elements
%================================================
function Hs = segmentObject_Callback(hObject,eventdata)

    Hs = guidata(gcbo);
    % button is clicked. change button text and start imfreehand
    set(Hs.btnHs,'Enable','off','BackgroundColor','white');
    set(Hs.startKey,'String','ESC to stop'); 
    hROI = imfreehand;  % add a new freehand 

    if numel(hROI) > 1
        delete(hROI);
        fprintf(1,'Segmented region resulted in 2 objects, deleted them\n'); 
    elseif ~isempty(hROI) 
        % Use the ROI mask binary image to append a new |image_object|  and
        % to update the image axes 
        maskImg = hROI.createMask;
        cc = bwconncomp(maskImg);
        if sum(maskImg(:)) < 50  % user drew a tiny (NULL) ROI
            fprintf(1,'Segmented region was too small to create object\n');
            delete(hROI);

            % imfreehand is done. change button text
            set(Hs.btnHs,'Enable','on','BackgroundColor','factory');
            set(Hs.clearSegment,'BackgroundColor','red');
            set(Hs.startKey,'String','alt/option');
            return
        end

        if cc.NumObjects > 1
            % ROI resulted in more than one region, keep only the largest region
            maxObj = 0;
            maxSize = 0;
            for p = 1:numel(cc.PixelIdxList)
                objSize = length(cc.PixelIdxList{p});
               if objSize >= maxSize
                    maxObj = p;
                    maxSize = objSize;
                end
            end
            cc.PixelIdxList = cc.PixelIdxList(maxObj);
            cc.NumObjects = 1;
            maskImg = false(size(maskImg));
            maskImg(cc.PixelIdxList{:}) = true;
            fprintf(1,'Fixed your mask with only largest image\n');
        end
        % should have one ROI, create & append an |image_object|
        fnumStr = sprintf('%03d',Hs.fileNum);
        
        newObj = improc2.buildImageObject(maskImg, fnumStr, Hs.dirPath);
        
        Hs.currObjs = [Hs.currObjs, newObj];
        
        Hs.allMasks = cat(3,Hs.allMasks,maskImg); % Store with other masks.
        delete(hROI);  % clear it from the image axes
        Hs = makeAndShowOverlay(Hs);
        Hs = updateDisplay(Hs);
    end

    % imfreehand is done. change button text
    set(Hs.btnHs,'Enable','on','BackgroundColor','factory');
    set(Hs.clearSegment,'BackgroundColor','red');
    set(Hs.startKey,'String','alt/option');

    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);


function undoSegment_Callback(hObject, eventdata)
% Button press to remove the last drawn segmentation.

    Hs = guidata(gcbo);
    if isempty(Hs.currObjs)
        printf(1,'NOTICE: Nothing to undo');
    elseif numel(Hs.currObjs) == 1
        Hs.allMasks = [];  % deletes last entry in the image masks
        Hs.currObjs = [];  % deletes last entry in array of |image_object|
    else
        Hs.allMasks = Hs.allMasks(:,:,1:end-1);  % deletes last entry in the image masks
        Hs.currObjs(end) = [];      % deletes last entry in array of |image_object|
    end

    Hs = makeAndShowOverlay(Hs);
    Hs = updateDisplay(Hs);

    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo, Hs);


function clearSegment_Callback(hObject, eventdata)
% Button press to remove the last drawn segmentation.
    Hs = guidata(gcbo);
    
    % make sure we have some segementations on this file number
    if numel(Hs.currObjs) == 0
        fprintf(1,'NOTICE: No segmentations to clear\n');
    else
        % ask user if they are sure about clearing segmentation here
        msg = sprintf('Clear the %d segmentations?',numel(Hs.currObjs));
        answer = questdlg(msg,'SegmentGUI','Yes','No','No');
        if strcmp(answer,'Yes')
            Hs.currObjs = [];
            Hs.allMasks = [];
            Hs = makeAndShowOverlay(Hs);
            Hs = updateDisplay(Hs);
        end
    end

    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo, Hs);


function nextFileB_Callback(hObject, eventdata)
% Button/key press to save the current set of segmentations to the 
% data***.mat file and then proceed to next set of image files.
    Hs = guidata(gcbo);

    % NEXT/SAVE button is clicked. Disable buttons to avoid double input
    set(Hs.btnHs,'Enable','off','BackgroundColor','white');
    set(Hs.nextFileB,'String','Loading...');
    drawnow;

    % Save the |image_object|s to data***.mat file
    objects = Hs.currObjs;
    save(sprintf('%s%sdata%03d.mat',Hs.dirPath,filesep,Hs.fileNum),'objects');
    [Hs.dataFiles,Hs.dataNums] = getDataFiles(Hs.dirPath);
    clear objects;
    Hs.currObjs = [];

    nextInd = find(Hs.fileNum == Hs.fileNums) + 1;
    if nextInd > numel(Hs.fileNums) % No files left, close the GUI.
        %-------------------------------
        % WE ARE ALL DONE, close the GUI
        delete(gcf)
        %-------------------------------
        return;
    elseif nextInd == numel(Hs.fileNums)  || numel(Hs.fileNums) == 1
        set(Hs.nextFileB,'String','Save & Quit');
    else
        set(Hs.nextFileB,'String','Save & Next');
    end

    % load the next set of data
    Hs.fileNum = Hs.fileNums(nextInd);
    Hs = loadFileSet(Hs);
    % NEXT/SAVE button actions done. Enable buttons
    set(Hs.btnHs,'Enable','on','BackgroundColor','factory');
    set(Hs.clearSegment,'BackgroundColor','red');
    drawnow;
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo, Hs);


function prevFileB_Callback(hObject, eventdata)
% Button/key press to save the current set of segmentations to the 
% data***.mat file and then return to previous set of image files.
    Hs = guidata(gcbo);

    prevInd = find(Hs.fileNum == Hs.fileNums) - 1;
    if prevInd < 1 % No files left, close the GUI.
        %-------------------------------
        % We are at the first file
        fprintf(1,'NOTICE: At the first set of image files\n');
        %-------------------------------
        return;
    end

    % PREV/SAVE button is clicked. Disable buttons to avoid double input
    set(Hs.btnHs,'Enable','off','BackgroundColor','white');
    set(Hs.prevFileB,'String','Loading...');
    drawnow;

    % Save the |image_object|s to data***.mat file
    objects = Hs.currObjs;
    save(sprintf('%s%sdata%03d.mat',Hs.dirPath,filesep,Hs.fileNum),'objects');
    clear objects;
    Hs.currObjs = [];

    % load the prev set of data
    Hs.fileNum = Hs.fileNums(prevInd);
    Hs = loadFileSet(Hs);
    % NEXT/SAVE button actions done. Enable buttons
    set(Hs.btnHs,'Enable','on','BackgroundColor','factory');
    set(Hs.clearSegment,'BackgroundColor','red');
    set(Hs.prevFileB,'String','Prev File');
    if numel(Hs.fileNums) ~= 1
        set(Hs.nextFileB,'String','Save & Next');
    end
    drawnow;
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);


function transCheck_Callback(hObject,eventdata)
% Checkbox to add/remove the trans image in the overlay
    Hs = guidata(gcbo);
    Hs = makeAndShowOverlay(Hs);
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);


function dapiCheck_Callback(hObject,eventdata)
% Checkbox to add/remove the dapi image in the overlay
    Hs = guidata(gcbo);
    Hs = makeAndShowOverlay(Hs);
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);


function channelMenu_Callback(hObject,eventdata)
% dropdown/popup menu to change which channel we use for display
    Hs = guidata(gcbo);

    channelInd = get(hObject,'Value');
    if strcmp(Hs.RNAchannels(channelInd),Hs.RNAchannel) 
        % chose the same channel as before, no change so just return
    else
        % New menu item selected. Disable buttons to avoid double input
        set(Hs.btnHs,'Enable','off','BackgroundColor','white');
        set(Hs.channelMenuLabel,'String','Loading...');
        drawnow;

        Hs.RNAchannel = cell2mat(Hs.RNAchannels(channelInd));
        Hs = getMaxes(Hs,false);
        Hs = makeAndShowOverlay(Hs);
    end

    % Files loaded, images shown. Enable buttons
    drawnow;
    set(Hs.btnHs,'Enable','on','BackgroundColor','factory');
    set(Hs.clearSegment,'BackgroundColor','red');
    set(Hs.channelMenuLabel,'String','RNA');

    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);
    
function checkboxContrast_Callback(hObject,eventdata)
% Checkbox to set manual contrast
    Hs = guidata(gcbo);
    Hs = makeAndShowOverlay(Hs);
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);

function contrastMaxVal_Callback(hObject,eventdata)
% Checkbox to add/remove the trans image in the overlay
    Hs = guidata(gcbo);
    Hs = makeAndShowOverlay(Hs);
    Hs = setFocusToFigure(Hs); % remove focus from uicontrol
    guidata(gcbo,Hs);



% WARNING!!!!  JAVAFRAME WILL BE DEPRECATED SOON!?!?! Who knows when but 
% this is the only viable option to return focus to the main figure after
% using one of the uicontrol objects. We need focus on the figure so we can
% use the figure1_KeyReleaseFcn easily without requiring clicking on the
% figure to get keyboard shortcuts
function Hs = setFocusToFigure(Hs)
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    javaFrame = get(Hs.figH,'JavaFrame');
    javaFrame.getAxisComponent.requestFocus;


function KeyPressCallback(src,evnt) 
%KeyPressFcn automatically takes in two inputs.  
%Src is the object that was active when the keypress occurred.  
%Evnt stores the data for the key pressed 
    Hs = guidata(src); 
    %Brings in the handles structure in to the function.  

    k = evnt.Key; %k is the key that is pressed.  

    if strcmp(k,'alt') %If alt was pressed.  
    pause(0.001) %Allows time to update.  
        %define hObject as the object of the callback that we are going to use
        %in this case, we are mapping the enter key to the add_object_button
        %therefore, we define hObject as the add pushbutton
        
        hObject = Hs.segmentObject;
        
        %call the segmentObject callback function.
        segmentObject_Callback(hObject, []);
        
        %Do the same thing to map to all the other callbacks.
    elseif strcmp(k,'backspace')
        pause(0.001)
        hObject=Hs.undoSegment;
        undoSegment_Callback(hObject,[]);
    elseif strcmp(k,'rightarrow')
        pause(0.001)
        hObject=Hs.nextFileB;
        nextFileB_Callback(hObject,[]);
    elseif strcmp(k,'leftarrow')
        pause(0.001)
        hObject=Hs.prevFileB;
        prevFileB_Callback(hObject,[]);
    end


function [Hs] = buildGUI(Hs,figH)
    Hs.imgAx = axes('Parent',figH,...
                    'Units','normalized',...
                    'Position',[0.009,0.012,.682,.97],...
                    'XTick',[],'YTick',[]);

    Hs.figTitle = uicontrol('Parent',figH,...
                            'Style','text',...
                            'String','SEGMENT','FontSize',40,...
                            'Units','normalized',...
                            'Position',[0.72 0.822 0.257 0.081],...
                            'ForegroundColor',[1 1 1],...
                            'BackgroundColor',[0.247 0.247 0.247]);
    Hs.segmentObject = uicontrol('Parent',figH,...
                        'Style','pushbutton',...
                        'Callback',@segmentObject_Callback,...
                        'Units','normalized',...
                        'Position',[0.788 0.704 0.119 0.048],...
                        'String','Start Segment');
    Hs.undoSegment  = uicontrol('Parent',figH,...
                        'Style','pushbutton',...
                        'Callback',@undoSegment_Callback,...
                        'Units','normalized',...
                        'Position',[0.788 0.616 0.119 0.048],...
                        'String','Undo Segment');
    Hs.clearSegment = uicontrol('Parent',figH,...
                        'Style','pushbutton',...
                        'Callback',@clearSegment_Callback,...
                        'Units','normalized',...
                        'Position',[0.788 0.520 0.119 0.048],...
                        'BackgroundColor',[0.6 0 0],...  % dark red
                        'ForegroundColor',[1 1 1],...
                        'String','Clear Field');
    btnHs = [Hs.clearSegment,Hs.segmentObject,Hs.undoSegment];
    set(btnHs,'FontSize',12,'FontWeight','bold');

    Hs.dapiCheck  = uicontrol('Parent',figH,...
                            'Style','checkbox',...
                            'Callback',@dapiCheck_Callback,...
                            'Units','normalized',...
                            'Position',[0.762 0.407 0.072 0.041],...
                            'String','DAPI','FontSize',12,...
                            'Value',1,'ForegroundColor',[1 1 1]);
    Hs.transCheck = uicontrol('Parent',figH,...
                            'Style','checkbox',...
                            'Callback',@transCheck_Callback,...
                            'Units','normalized',...
                            'Position',[0.857 0.407 0.076 0.041],...
                            'String','Trans','FontSize',12,...
                            'Value',1,'ForegroundColor',[1 1 1]);
    if ~any(strcmp(Hs.foundChannels,'dapi'))
        set(Hs.dapiCheck,'Visible','off')
    end
    if ~any(strcmp(Hs.foundChannels,'trans'))
        set(Hs.transCheck,'Visible','off')
    end

    Hs.channelMenuLabel = uicontrol('Parent',figH,...
                            'Style','text','String','RNA',...
                            'Units','normalized',...
                            'Position',[0.764 0.323 0.065 0.037],...
                            'BackgroundColor',[0.247 0.247 0.247],...
                            'FontSize',14,'ForegroundColor',[1 1 1]);
    Hs.channelMenu = uicontrol('Parent',figH,...
                            'Style','popupmenu',...
                            'Callback',@channelMenu_Callback,...
                            'Units','normalized',...
                            'String',Hs.RNAchannels,...
                            'Position',[0.836 0.317 0.093 0.048]);
                        
    Hs.checkboxContrast = uicontrol('Parent',figH,...
                            'Style','checkbox','String','Manual contrast',...
                            'Callback',@checkboxContrast_Callback,...                            
                            'Value',0,...
                            'Units','normalized',...
                            'Position',[0.704 0.283 0.165 0.037],...
                            'BackgroundColor',[0.247 0.247 0.247],...
                            'FontSize',14,'ForegroundColor',[1 1 1]);
                        
    Hs.contrastMaxVal = uicontrol('Parent',figH,...
                            'Style','edit','String','NA',...
                            'Callback',@contrastMaxVal_Callback,...                            
                            'Units','normalized',...
                            'Position',[0.864 0.283 0.065 0.037],...
                            'BackgroundColor',[0.247 0.247 0.247],...
                            'FontSize',14,'ForegroundColor',[1 1 1]);
                        
    Hs.prevFileB = uicontrol('Parent',figH,...
                            'Style','pushbutton',...
                            'Callback',@prevFileB_Callback,...
                            'Units','normalized',...
                            'Position',[0.743 0.233 0.1 0.048],...
                            'String','Prev File');
    Hs.nextFileB = uicontrol('Parent',figH,...
                            'Style','pushbutton',...
                            'Callback',@nextFileB_Callback,...
                            'Units','normalized',...
                            'Position',[0.851 0.233 0.1 0.048]);
    if numel(Hs.fileNums) == 1
        set(Hs.nextFileB,'String','Save & Quit');
        set(Hs.prevFileB,'Enable','off');
    else
        set(Hs.nextFileB,'String','Save & Next');
    end
    set([Hs.prevFileB Hs.nextFileB],'FontSize',12,'FontWeight','bold');

    Hs.startKey = uicontrol('Parent',figH,'style','text',...
                            'String','alt/option',...
                            'Units','normalized',...
                            'Position',[0.79 0.675 0.115 0.03]);
    Hs.undoKey = uicontrol('Parent',figH,'style','text',...
                            'String','backspace',...
                            'Units','normalized',...
                            'Position',[0.811 0.587 0.073 0.03]);
    Hs.prevKey = uicontrol('Parent',figH,'style','text',...
                            'String','left arrow',...
                            'Units','normalized',...
                            'Position',[0.758 0.206 0.073 0.03]);
    Hs.nextKey = uicontrol('Parent',figH,'style','text',...
                            'String','right arrow',...
                            'Units','normalized',...
                            'Position',[0.865 0.208 0.073 0.03]);
    labels = [Hs.startKey Hs.undoKey Hs.nextKey Hs.prevKey];
    set(labels,'BackgroundColor',[0.247 0.247 0.247],...
               'ForegroundColor',[1 1 1]);
                        
    Hs.statsPanel = uipanel('Parent',figH,'Title','Stats',...
                            'Units','normalized',...
                            'Position',[0.751 0.055 0.197 0.129],...
                            'BackgroundColor',[0.929 0.929 0.929]);
    Hs.savedLabel = uicontrol('Parent',Hs.statsPanel,'Style','text',...
                            'String','Saved Objects:',...
                            'Units','normalized',...
                            'Position',[0.039 0.667 0.632 0.250],...
                            'FontSize',12);
    Hs.filenumLabel = uicontrol('Parent',Hs.statsPanel,'Style','text',...
                            'String','File Number:',...
                            'Units','normalized',...
                            'Position',[0.039 0.2 0.536 0.243],...
                            'FontSize',12);
    Hs.numSaved = uicontrol('Parent',Hs.statsPanel,'Style','text',...
                            'String','0',...
                            'Units','normalized',...
                            'Position',[0.671 0.667 0.232 0.25],...
                            'FontSize',12,'FontWeight','bold');
    Hs.fileProgress = uicontrol('Parent',Hs.statsPanel,'Style','text',...
                            'String',sprintf('1 / %d',numel(Hs.fileNums)),...
                            'Units','normalized',...
                            'Position',[0.623 0.217 0.331 0.25],...
                            'FontSize',12,'FontWeight','bold');

    % Collect all UIControl handles that need to be enable/disabled 
    % when turning off/on Segmenting mode
    Hs.btnHs = [Hs.dapiCheck Hs.transCheck Hs.segmentObject Hs.nextFileB ...
                Hs.prevFileB Hs.clearSegment Hs.channelMenu Hs.undoSegment];
