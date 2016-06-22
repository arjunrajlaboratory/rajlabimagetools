function IntronExonTxnSiteGUIcore(navigator, baseTxnSitesCollection, imageHolders)
%GuiCore called when passed both intron and exon channels
gui = improc2.txnSites2.layOutGUI();

%Gui control handles
imgAx = gui.imgAx;
figH = gui.figH;
zoomButton = gui.zoomButton;
addButton = gui.addButton;
panButton = gui.panButton;
intronMultiplierTextBox = gui.intronMultiplierTextBox;
exonMultiplierTextBox = gui.exonMultiplierTextBox;
deleteLastButton = gui.deleteLastButton;
clearAllButton = gui.clearAllButton;
channelSelect = gui.channelSelect;

%ImageHandlers
intronImageHolder = imageHolders.intron;

exonImageHolder = imageHolders.exon;

dapiImageHolder = imageHolders.dapi;

%Gui allows user to specify relative contrast between exons and introns.
%For example if the intron background is high, it might help to increase
%the exon image values
paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
    struct('intronMultiplier', 1.0, 'exonMultiplier', 1.0));

UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
    paramsForComposite);

UIToParamsForComposite.attachUIControl('intronMultiplier', intronMultiplierTextBox)
UIToParamsForComposite.attachUIControl('exonMultiplier', exonMultiplierTextBox)


%Draws the initial image - Composite Image maker takes the exon and intron
%image. If the user specifies a specific channel, Popindex_selected acts as
%a flag in composite Image maker which may call composite image maker for a
%single channel
Popitems = get(channelSelect ,'String');
Popindex_selected = get(channelSelect,'Value');
Popitem_selected = Popitems{Popindex_selected};
compositeImageMaker = improc2.txnSites2.CompositeImageMaker(exonImageHolder, ...
    intronImageHolder, dapiImageHolder, paramsForComposite, Popitem_selected);
sizeAdaptiveViewportHolder = improc2.utils.ImageSizeAdaptiveViewportHolder(intronImageHolder);
viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
compositeImageDisplayer = improc2.utils.ImageDisplayer(imgAx, compositeImageMaker, viewportHolder);
txnSitesCollection = improc2.txnSites2.utils.NotifyingTranscriptionSitesCollection(...
    baseTxnSitesCollection);
txnSitesDisplayer = improc2.txnSites2.utils.TranscriptionSitesDisplayer(imgAx, txnSitesCollection, baseTxnSitesCollection);

mainWindowDisplayer = dentist.utils.DisplayerSequence(...
    compositeImageDisplayer, txnSitesDisplayer);
mainWindowDisplayer.draw();
UIToParamsForComposite.addActionAfterSettingAnyValue(mainWindowDisplayer, @draw)

%Interpreter that collects the clicked position and passes it to the
%txnsitecollection to be added to data
txnSiteAddingInterpreter = ...
    improc2.txnSites2.utils.TranscriptionSiteAddingInterpreter(txnSitesCollection);

zoomInterpreter = dentist.utils.ImageZoomingMouseInterpreter(viewportHolder);

panningInterpreter = dentist.utils.ImagePanningMouseInterpreter(viewportHolder);

viewportHolder.addActionAfterViewportSetting(mainWindowDisplayer, @draw);

txnSitesCollection.addActionAfterChangeOfNumTxnSites(txnSitesDisplayer, @draw);

set(deleteLastButton, 'Callback', @(varargin) txnSitesCollection.deleteLastTranscriptionSite());
set(clearAllButton, 'Callback', @(varargin) txnSitesCollection.clearAllTranscriptionSites());
set(channelSelect, 'Callback', {@popupCallBack, imageHolders, paramsForComposite, imgAx, baseTxnSitesCollection});

buttonStruct = struct(...
    'zoom', zoomButton, ...
    'pan', panButton, ...
    'add', addButton ...
    );
actionOnSelect = struct(...
    'zoom', @() zoomInterpreter.wireToFigureAndAxes(figH, imgAx), ...
    'pan',  @() panningInterpreter.wireToFigureAndAxes(figH, imgAx), ...
    'add', @() txnSiteAddingInterpreter.wireToFigureAndAxes(figH, imgAx) ...
    );
actionOnDeselect = struct(...
    'zoom', @zoomInterpreter.unwire, ...
    'pan',  @panningInterpreter.unwire, ...
    'add', @txnSiteAddingInterpreter.unwire ...
    );

zoomPanAddToggler = dentist.utils.FunctionExecutingToggleGroup(...
    buttonStruct, actionOnSelect, actionOnDeselect);

zoomPanAddToggler.initialize('add');

zoomAddTwoWaySwitcher = improc2.txnSites2.utils.TwoWayActionAlternator(...
    @() zoomPanAddToggler.activateButton('add'), ...
    @() zoomPanAddToggler.activateButton('zoom'));

improc2.NavigatorGUI(navigator);

nextImage = improc2.txnSites2.NextImageDisplayer(imageHolders, paramsForComposite, imgAx, baseTxnSitesCollection, channelSelect);
navigator.addActionAfterMoveAttempt(nextImage, @nextImageDisplay)


unimplementedRNAChannelSwitch = [];
keyboardCommandInterpreter = improc2.utils.NavigationKeyboardInterpreter(...
    navigator, unimplementedRNAChannelSwitch);

set(gui.figH, 'WindowKeyPressFcn', @keyboardCommandInterpreter.keyPressCallBackFunc)





% keyboardCommandInterpreter.addKeyPressCommand({'1'}, ...
%     @() zoomPanAddToggler.activateButton('zoom'))
%
% keyboardCommandInterpreter.addKeyPressCommand({'2'}, ...
%     @() zoomPanAddToggler.activateButton('pan'))
%
% keyboardCommandInterpreter.addKeyPressCommand({'3'}, ...
%     @() zoomPanAddToggler.activateButton('add'))

keyboardCommandInterpreter.addKeyPressCommand({'w', 'W', 's', 'S'}, ...
    @zoomAddTwoWaySwitcher.doOtherAction);
end

%CallBack function for the popupmenu
function popupCallBack(hObject, evn, imageHolders, paramsForComposite, imgAx, baseTxnSitesCollection)
items = get(hObject,'String');
index_selected = get(hObject,'Value');
item_selected = items{index_selected};
compositeImageMaker = improc2.txnSites2.CompositeImageMaker(imageHolders.exon, ...
    imageHolders.intron, imageHolders.dapi, paramsForComposite, ...
    item_selected);
sizeAdaptiveViewportHolder = improc2.utils.ImageSizeAdaptiveViewportHolder(imageHolders.intron);
viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);

compositeImageDisplayer = improc2.utils.ImageDisplayer(imgAx, compositeImageMaker, viewportHolder);
txnSitesCollection = improc2.txnSites2.utils.NotifyingTranscriptionSitesCollection(...
    baseTxnSitesCollection);

txnSitesDisplayer = improc2.txnSites2.utils.TranscriptionSitesDisplayer(imgAx, txnSitesCollection);

mainWindowDisplayer = dentist.utils.DisplayerSequence(...
    compositeImageDisplayer, txnSitesDisplayer);

mainWindowDisplayer.draw();
end


