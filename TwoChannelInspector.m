function out = TwoChannelInspector(objectHandle, twoChanNode) %,guideChannel,snpChannel1,snpChannel2)

fig = figure;

% Get results of the colocalization
results = objectHandle.getData(twoChanNode); % accept different node names
chan1channel = results.idMap.channels{1};
chan2channel  = results.idMap.channels{2};
% snpChannel2  = results.snpMap.channels{3};

chan1name = results.idMap.names{1}; % clearly label subplots on viewer
chan2name = results.idMap.names{2};
% snpName2 = results.snpMap.names{3};

R = objectHandle.getBoundingBox;


img_chan1 = readmm(objectHandle.getImageFileName(chan1channel));

img_chan2 = readmm(objectHandle.getImageFileName(chan2channel));
% img_cy = readmm(objectHandle.getImageFileName(snpChannel2));
img_dapi = readmm(objectHandle.getImageFileName('dapi'));


chan1stack = rectcropmulti(img_chan1.imagedata,R);
% cy1stack = rectcropmulti(img_cy.imagedata,R);
chan2stack = rectcropmulti(img_chan2.imagedata,R);

chan1Spots = results.data.(chan1channel).position;
chan2Spots  = results.data.(chan2channel).position;
% SNP2Spots  = results.data.(snpChannel2).position;

chan1chan2index = results.data.(chan1channel).chan2_ID > 0;
% guideSNP2index = results.data.(chan1Channel).snpB_ID > 0;

chan2chan1index = results.data.(chan1channel).chan2_ID(chan1chan2index);
% SNP2guideindex = results.data.(chan1Channel).snpB_ID(guideSNP2index);

% % Convert back from "deformed" z coords to normal z coords.
% guideSpots(:,3) = guideSpots(:,3)/results.zDeform;
% SNP1Spots(:,3)  = SNP1Spots(:,3) /results.zDeform;
% SNP2Spots(:,3)  = SNP2Spots(:,3) /results.zDeform;

currentZ = 1; % default
alldata.currentZ = currentZ;
alldata.chan1stack = chan1stack;
alldata.chan2stack = chan2stack;
% alldata.cy1stack = cy1stack;
alldata.chan1Spots = chan1Spots;

% alldata.results.zDeform = results.zDeform;
alldata.results.xyPixelDistance = results.xyPixelDistance;
alldata.results.zStepSize = results.zStepSize;

alldata.chan1Spots = chan1Spots;
alldata.chan2Spots = chan2Spots;
% alldata.SNP2Spots = SNP2Spots;
alldata.chan1chan2index = chan1chan2index;
% alldata.guideSNP2index = guideSNP2index;
alldata.chan2chan1index = chan2chan1index;
% alldata.SNP2guideindex = SNP2guideindex;

alldata.chan1name = chan1name;
alldata.chan1channel = chan1channel;

alldata.chan2name = chan2name;
% alldata.snp2name = snpName2;
alldata.chan2channel = chan2channel;
% alldata.snp2channel = snpChannel2;


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
sz = size(alldata.chan1stack);
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
chan1stack = alldata.chan1stack;
chan2stack = alldata.chan2stack;
% cy1stack = alldata.cy1stack;
chan1Spots = alldata.chan1Spots;
% results.zDeform = alldata.results.zDeform;
results.zStepSize = alldata.results.zStepSize;
results.xyPixelDistance = alldata.results.xyPixelDistance;

chan1Spots = alldata.chan1Spots;
chan2Spots = alldata.chan2Spots;
% SNP2Spots = alldata.SNP2Spots;
chan1chan2index = alldata.chan1chan2index;
% guideSNP2index = alldata.guideSNP2index;
chan2chan1index = alldata.chan2chan1index;
% SNP2guideindex = alldata.SNP2guideindex;

% Second
% For maintaining zoom level
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
subplot(1,2,1);

if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(chan1stack(:,:,currentZ),[]);
else
    imshow(chan1stack(:,:,currentZ),[min(chan1stack(:)) max(chan1stack(:))]);
end

% imshow(al1stack(:,:,currentZ),[]);
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocations(chan1Spots,currentZ,'wo')
showSpotLocations(chan2Spots(chan2chan1index,:), currentZ,'ro')
% showSpotLocations(SNP2Spots(SNP2guideindex,:), currentZ,'co')
hold off
title(['z = ', num2str(currentZ), '; ', alldata.chan1channel, ' label: ', alldata.chan1name]);
ax1 = gca;

% First
if ~alldata.firstshowing
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
end
subplot(1,2,2);

if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
    imshow(chan2stack(:,:,currentZ),[]);
else
    imshow(chan2stack(:,:,currentZ),[min(chan2stack(:)) max(chan2stack(:))]);
end

% imshow(tm1stack(:,:,currentZ),[]);
if ~alldata.firstshowing
    set(gca, 'XLim', xlim);
    set(gca, 'YLim', ylim);
end
hold on
showSpotLocations(chan2Spots,currentZ,'ro')
showSpotLocations(chan1Spots(chan1chan2index,:),currentZ,'wo')
hold off
title([alldata.chan2channel, ' label: ', alldata.chan2name]);
ax2 = gca;

% % Third
% if ~alldata.firstshowing
%     xlim = get(gca,'XLim');
%     ylim = get(gca,'YLim');
% end
% subplot(1,3,3);
% 
% if strcmp(alldata.bg.SelectedObject.String,'Scale individual planes')
%     imshow(cy1stack(:,:,currentZ),[]);
% else
%     imshow(cy1stack(:,:,currentZ),[min(cy1stack(:)) max(cy1stack(:))]);
% end
% 
% % imshow(cy1stack(:,:,currentZ),[]);
% if ~alldata.firstshowing
%     set(gca, 'XLim', xlim);
%     set(gca, 'YLim', ylim);
% end
% hold on
% showSpotLocations(SNP2Spots,currentZ,'co')
% showSpotLocations(chan1Spots(guideSNP2index,:),currentZ,'wo')
% hold off
% title([alldata.snp2channel, ' label: ', alldata.snp2name]);
% ax3 = gca;

linkaxes([ax1 ax2]);
end
