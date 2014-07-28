% function tools = launchIntronExonTxnSiteGUI(exonChannelName, intronChannelName, varargin)

% future gui function starts here:
% arguments would be:
% exonChannelName
% intronChannelName
% tools
% baseTxnSitesCollection

function IntronExonTxnSiteGUIcore(navigator, baseTxnSitesCollection, imageHolders)

gui = improc2.txnSites.layOutGUI();

imgAx = gui.imgAx;
figH = gui.figH;
zoomButton = gui.zoomButton;
addButton = gui.addButton;
panButton = gui.panButton;
intronMultiplierTextBox = gui.intronMultiplierTextBox;
exonMultiplierTextBox = gui.exonMultiplierTextBox;
deleteLastButton = gui.deleteLastButton;
clearAllButton = gui.clearAllButton;

intronImageHolder = imageHolders.intron;

exonImageHolder = imageHolders.exon;

dapiImageHolder = imageHolders.dapi;

paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
    struct('intronMultiplier', 1.0, 'exonMultiplier', 1.0));

UIToParamsForComposite = improc2.utils.UISynchronizedNamedValuesAndChoices(...
    paramsForComposite);

UIToParamsForComposite.attachUIControl('intronMultiplier', intronMultiplierTextBox)
UIToParamsForComposite.attachUIControl('exonMultiplier', exonMultiplierTextBox)




compositeImageMaker = improc2.txnSites.CompositeImageMaker(exonImageHolder, ...
    intronImageHolder, dapiImageHolder, paramsForComposite);

sizeAdaptiveViewportHolder = improc2.utils.ImageSizeAdaptiveViewportHolder(intronImageHolder);
viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);

compositeImageDisplayer = improc2.utils.ImageDisplayer(imgAx, compositeImageMaker, viewportHolder);



txnSitesCollection = improc2.txnSites.utils.NotifyingTranscriptionSitesCollection(...
    baseTxnSitesCollection);

txnSitesDisplayer = improc2.txnSites.utils.TranscriptionSitesDisplayer(imgAx, txnSitesCollection);

mainWindowDisplayer = dentist.utils.DisplayerSequence(...
    compositeImageDisplayer, txnSitesDisplayer);

mainWindowDisplayer.draw();

UIToParamsForComposite.addActionAfterSettingAnyValue(mainWindowDisplayer, @draw)


txnSiteAddingInterpreter = ...
    improc2.txnSites.utils.TranscriptionSiteAddingInterpreter(txnSitesCollection);

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

zoomAddTwoWaySwitcher = improc2.txnSites.utils.TwoWayActionAlternator(...
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


