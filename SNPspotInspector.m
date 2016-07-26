function out = SNPspotInspector(objectHandle,currentZ,snpNode) %,guideChannel,snpChannel1,snpChannel2)

fig = figure;

% Get results of the colocalization
results = objectHandle.getData(snpNode); % accept different node names
guideChannel = results.snpMap.channels{1};
snpChannel1  = results.snpMap.channels{2};
snpChannel2  = results.snpMap.channels{3};

guideName = results.snpMap.names{1}; % clearly label subplots on viewer
snpName1 = results.snpMap.names{2};
snpName2 = results.snpMap.names{3};

R = objectHandle.getBoundingBox;


img_alexa = readmm(objectHandle.getImageFileName(guideChannel));

img_tmr = readmm(objectHandle.getImageFileName(snpChannel1));
img_cy = readmm(objectHandle.getImageFileName(snpChannel2));
img_dapi = readmm(objectHandle.getImageFileName('dapi'));


al1stack = rectcropmulti(img_alexa.imagedata,R);
cy1stack = rectcropmulti(img_cy.imagedata,R);
tm1stack = rectcropmulti(img_tmr.imagedata,R);

guideSpots = results.data.(guideChannel).position;
SNP1Spots  = results.data.(snpChannel1).position;
SNP2Spots  = results.data.(snpChannel2).position;

guideSNP1index = results.data.(guideChannel).snpA_ID > 0;
guideSNP2index = results.data.(guideChannel).snpB_ID > 0;

SNP1guideindex = results.data.(guideChannel).snpA_ID(guideSNP1index);
SNP2guideindex = results.data.(guideChannel).snpB_ID(guideSNP2index);

% % Convert back from "deformed" z coords to normal z coords.
% guideSpots(:,3) = guideSpots(:,3)/results.zDeform;
% SNP1Spots(:,3)  = SNP1Spots(:,3) /results.zDeform;
% SNP2Spots(:,3)  = SNP2Spots(:,3) /results.zDeform;

alldata.currentZ = currentZ;
alldata.al1stack = al1stack;
alldata.tm1stack = tm1stack;
alldata.cy1stack = cy1stack;
alldata.guideSpots = guideSpots;

alldata.results.zDeform = results.zDeform;
alldata.results.xyPixelDistance = results.xyPixelDistance;
alldata.results.zStepSize = results.zStepSize;

alldata.guideSpots = guideSpots;
alldata.SNP1Spots = SNP1Spots;
alldata.SNP2Spots = SNP2Spots;
alldata.guideSNP1index = guideSNP1index;
alldata.guideSNP2index = guideSNP2index;
alldata.SNP1guideindex = SNP1guideindex;
alldata.SNP2guideindex = SNP2guideindex;

alldata.snp1name = snpName1;
alldata.snp2name = snpName2;
alldata.snp1channel = snpChannel1;
alldata.snp2channel = snpChannel2;


alldata.firstshowing = true;

ButtonUpZ=uicontrol('Parent',fig,'Style','pushbutton','String','Up Z','Units','normalized','Position',[0.1 0.9 0.075 0.075],'Visible','on','Callback',@increaseZcallback);
ButtonDnZ=uicontrol('Parent',fig,'Style','pushbutton','String','Down Z','Units','normalized','Position',[0.0 0.9 0.075 0.075],'Visible','on','Callback',@decreaseZcallback);

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
sz = size(alldata.al1stack);
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
al1stack = alldata.al1stack;
tm1stack = alldata.tm1stack;
cy1stack = alldata.cy1stack;
guideSpots = alldata.guideSpots;
results.zDeform = alldata.results.zDeform;
results.zStepSize = alldata.results.zStepSize;
results.xyPixelDistance = alldata.results.xyPixelDistance;

guideSpots = alldata.guideSpots;
SNP1Spots = alldata.SNP1Spots;
SNP2Spots = alldata.SNP2Spots;
guideSNP1index = alldata.guideSNP1index;
guideSNP2index = alldata.guideSNP2index;
SNP1guideindex = alldata.SNP1guideindex;
SNP2guideindex = alldata.SNP2guideindex;

% Second
% For maintaining zoom level
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
subplot(1,3,2);

if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(al1stack(:,:,currentZ),[]);
else
    imshow(al1stack(:,:,currentZ),[min(al1stack(:)) max(al1stack(:))]);
end

% imshow(al1stack(:,:,currentZ),[]);
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocations(guideSpots,currentZ,'wo')
showSpotLocations(SNP1Spots(SNP1guideindex,:), currentZ,'ro')
showSpotLocations(SNP2Spots(SNP2guideindex,:), currentZ,'co')
hold off
title(['z = ' num2str(currentZ)]);
ax1 = gca;

% First
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
subplot(1,3,1);

if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(tm1stack(:,:,currentZ),[]);
else
    imshow(tm1stack(:,:,currentZ),[min(tm1stack(:)) max(tm1stack(:))]);
end

% imshow(tm1stack(:,:,currentZ),[]);
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocations(SNP1Spots,currentZ,'ro')
showSpotLocations(guideSpots(guideSNP1index,:),currentZ,'wo')
hold off
title([alldata.snp1channel, ' label: ', alldata.snp1name]);
ax2 = gca;

% Third
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
subplot(1,3,3);

if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(cy1stack(:,:,currentZ),[]);
else
    imshow(cy1stack(:,:,currentZ),[min(cy1stack(:)) max(cy1stack(:))]);
end

% imshow(cy1stack(:,:,currentZ),[]);
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocations(SNP2Spots,currentZ,'co')
showSpotLocations(guideSpots(guideSNP2index,:),currentZ,'wo')
hold off
title([alldata.snp2channel, ' label: ', alldata.snp2name]);
ax3 = gca;

linkaxes([ax1 ax2 ax3]);
end
