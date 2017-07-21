function ExonOnlyTxnSiteGUIcore(navigator, baseTxnSitesCollection, imageHolders, additionalChannels)
%GuiCore called when only the exon channel is passed
gui = improc2.txnSites2.layOutGUI( additionalChannels);

%Gui control handles. The handles referring to introns are not present, but
%objects still exsist in the layout - they appear there but have no
%functionality
imgAx = gui.imgAx;
figH = gui.figH;
zoomButton = gui.zoomButton;
addButton = gui.addButton;
panButton = gui.panButton;
exonMultiplierTextBox = gui.exonMultiplierTextBox;
deleteLastButton = gui.deleteLastButton;
clearAllButton = gui.clearAllButton;

%ImageHandlers
exonImageHolder = imageHolders.exon;
dapiImageHolder = imageHolders.dapi;

paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
    struct('exonMultiplier', 1.0));

UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
    paramsForComposite);

UIToParamsForComposite.attachUIControl('exonMultiplier', exonMultiplierTextBox)

%Draw the image for the first object
compositeImageMaker = improc2.txnSites2.CompositeExonImageMaker(exonImageHolder, ...
    dapiImageHolder, paramsForComposite);

sizeAdaptiveViewportHolder = improc2.utils.ImageSizeAdaptiveViewportHolder(exonImageHolder);
viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);

compositeImageDisplayer = improc2.utils.ImageDisplayer(imgAx, compositeImageMaker, viewportHolder);

txnSitesCollection = improc2.txnSites2.utils.NotifyingTranscriptionSitesCollection(...
    baseTxnSitesCollection);

txnSitesDisplayer = improc2.txnSites2.utils.TranscriptionSitesDisplayer(imgAx, txnSitesCollection);

mainWindowDisplayer = dentist.utils.DisplayerSequence(...
    compositeImageDisplayer, txnSitesDisplayer);

mainWindowDisplayer.draw();

UIToParamsForComposite.addActionAfterSettingAnyValue(mainWindowDisplayer, @draw)



txnSiteAddingInterpreter = ...
    improc2.txnSites2.utils.TranscriptionSiteAddingInterpreter(txnSitesCollection);

zoomInterpreter = dentist.utils.ImageZoomingMouseInterpreter(viewportHolder);

panningInterpreter = dentist.utils.ImagePanningMouseInterpreter(viewportHolder);

viewportHolder.addActionAfterViewportSetting(mainWindowDisplayer, @draw);

txnSitesCollection.addActionAfterChangeOfNumTxnSites(txnSitesDisplayer, @draw);

set(deleteLastButton, 'Callback', @(varargin) txnSitesCollection.deleteLastTranscriptionSite());
set(clearAllButton, 'Callback', @(varargin) txnSitesCollection.clearAllTranscriptionSites());

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
navigator.addActionAfterMoveAttempt(mainWindowDisplayer, @draw)


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


