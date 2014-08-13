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
function CT = shiftTiles(filePaths, foundChannels)
    Hs = dentist.shift.createAndLayoutMainGUI();
    display('Shift GUI launched');
    positionText = dentist.shift.PositionTextBox(Hs.positionTextBox);
    imageProvider = dentist.shift.ImageProvider(filePaths, Hs.borderCheck, positionText);
    keyInterpreter = dentist.shift.KeyPressInterpreter(Hs.figH);
    axesManager = dentist.shift.AxesManager(Hs.imgAx, Hs.figH, imageProvider, keyInterpreter);
    keyInterpreter.setAxesManager(axesManager);
    panelInterpreter = dentist.shift.PanelInterpreter(axesManager, Hs.imgAx);
    panelInterpreter.wireToFigureAndAxes(Hs.figH, Hs.imgAx);
    axesManager.setPanelInterpreter(panelInterpreter);
    
    CT.imageProvider = imageProvider;
    CT.axesManager = axesManager;
    
    dentist.shift.ChannelDropDown(Hs.chanDropDown,foundChannels, imageProvider,...
        axesManager);
    dentist.shift.BorderCheck(Hs.borderCheck, imageProvider, axesManager);
    
    set(Hs.nextButton, 'Callback',{@nextButtonCallback, imageProvider,...
        axesManager, Hs.figH});
    set(Hs.prevButton, 'Callback',{@previousButtonCallback, imageProvider,...
        axesManager, Hs.figH});
    set(Hs.bringFrontButton, 'Callback',{@bringToFrontCallback, axesManager,...
        Hs.figH});
    set(Hs.processTilesButton, 'Callback',{@processTilesCallBack,...
        imageProvider, axesManager, foundChannels});
    set(Hs.randomButton, 'Callback', {@randomButtonCallback, imageProvider,...
        axesManager, Hs.figH});
    set(Hs.analyzeButton, 'Callback', {@analyzeButtonCallback, axesManager});
    set(Hs.contrastButton, 'Callback', {@contrastButtonCallback, imageProvider,...
        axesManager});
    set(Hs.exitButton, 'Callback', {@exitButtonCallback, Hs.figH});
    axesManager.displayImage();
    
    uiwait(Hs.figH);
    
end
function exitButtonCallback(hObject, eventData, figH)
    uiresume(figH);
    delete(figH);
end
function analyzeButtonCallback(hObject, eventData, axesManager)
    figure,imshow(axesManager.lastImage);
end
function contrastButtonCallback(hObject, eventData, imageProvider, axesManager)
    if get(hObject,'Value') == 1
        imageProvider.contrastButtonDown = true;
    else
        imageProvider.contrastButtonDown = false;
    end
    axesManager.displayImage();
end
function nextButtonCallback(hObject, eventData, imageProvider, axesManager, figH)
    imageProvider.moveToNextImageSet();
    axesManager.displayImage();
    setFocusToFigure(figH);
end
function previousButtonCallback(hObject, eventData, imageProvider, axesManager, figH)
    imageProvider.moveToPreviousImageSet();
    axesManager.displayImage();
    setFocusToFigure(figH);
end
function bringToFrontCallback(hObject, eventData, axesManager, figH)
    axesManager.bringSelectedToFront();
    setFocusToFigure(figH);
end
function randomButtonCallback(hObject, eventData, imageProvider, axesManager, figH)
    imageProvider.moveToRandomImageSet();
    axesManager.displayImage();
    setFocusToFigure(figH);
end
function processTilesCallBack(hObject, eventData, imageProvider,...
    axesManager, foundChannels)
    imageProvider.filePaths
    imageProvider.imageSize
    
    dentist.shift.process.processTiles(imageProvider.filePaths, imageProvider.imageSize,...
        axesManager.rightUL, axesManager.downUL, foundChannels)
end
function setFocusToFigure(figH)
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    javaFrame = get(figH,'JavaFrame');
    javaFrame.getAxisComponent.requestFocus;
end



