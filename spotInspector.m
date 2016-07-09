function spotInspector(objectHandle,channel)

R = objectHandle.getBoundingBox;
img = readmm(objectHandle.getImageFileName(channel));

imStack = rectcropmulti(img.imagedata,R);

results = objectHandle.getData(channel);
[x,y,z] = results.getSpotCoordinates;

spots = [y x z];


fig = figure;

currentZ = 1;

alldata.currentZ = currentZ;
alldata.imStack = imStack;
alldata.spots = spots;

alldata.firstshowing = true;

ButtonUpZ=uicontrol('Parent',fig,'Style','pushbutton','String','Up Z','Units','normalized','Position',  [0.0 0.9 0.1 0.075],'Visible','on','Callback',@increaseZcallback);
ButtonDnZ=uicontrol('Parent',fig,'Style','pushbutton','String','Down Z','Units','normalized','Position',[0.0 0.8 0.1 0.075],'Visible','on','Callback',@decreaseZcallback);

% Add scaling radio button
bg = uibuttongroup('Visible','on',...
    'Position',[0 0 0.5 .08],...
    'SelectionChangedFcn',@contrastSelection);

% Create two radio buttons in the button group.
r1 = uicontrol(bg,'Style',...
    'radiobutton',...
    'String','Scale individual planes',...
    'Position',[5 5 150 20],...
    'HandleVisibility','on');

r2 = uicontrol(bg,'Style','radiobutton',...
    'String','Scale entire stack',...
    'Position',[150 5 150 20],...
    'HandleVisibility','on');
bg.Visible = 'on';

alldata.bg = bg;

showSpots(alldata);

alldata.firstshowing = false;
setappdata(fig,'alldata',alldata);
end

function increaseZcallback(hObject,eventdata)
alldata = getappdata(hObject.Parent,'alldata');
sz = size(alldata.imStack);
alldata.currentZ = min(sz(3),alldata.currentZ + 1);
setappdata(hObject.Parent,'alldata',alldata);
showSpots(alldata);
end

function decreaseZcallback(hObject,eventdata)
alldata = getappdata(hObject.Parent,'alldata');
alldata.currentZ = max(alldata.currentZ - 1,1);
setappdata(hObject.Parent,'alldata',alldata);
showSpots(alldata);
end

function contrastSelection(hObject,callbackdata)
alldata = getappdata(hObject.Parent,'alldata');
showSpots(alldata);
end

function showSpots(alldata)

currentZ = alldata.currentZ;
imStack = alldata.imStack;
spots = alldata.spots;

% For maintaining zoom level
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(imStack(:,:,currentZ),[]);
else
    imshow(imStack(:,:,currentZ),[min(imStack(:)) max(imStack(:))]);
end
set(gca,'YDir','normal')
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocationstemp(spots,currentZ,'wo')
hold off
title(['z = ' num2str(currentZ)]);
end
