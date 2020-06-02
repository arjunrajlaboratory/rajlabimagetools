function outStruct = launchGUI2Core(tools, channels, varargin)
%GuiCore called when passed both intron and exon channels
objectHandle = tools.objectHandle;
ip = inputParser;
ip.addParameter('nodeName', 'ManuallyClickedSpots', @ischar);
ip.parse(varargin{:});


gui = improc2.txnSites3.layOutGUI(channels);

%Gui control handles
% imgAx = p.imgAx;
figH = gui.figH;

% addPointsButtonHandle = gui.addPointsButtonHandle;
% deselectAllButtonHandle = gui.deselectAllButtonHandle;
% deletePointsButtonHandle = gui.deletePointsButtonHandle;


%ImageHandlers


    set(gui.prevObj, 'CallBack', @(varargin) tools.navigator.tryToGoToPrevObj())
    set(gui.nextObj, 'CallBack', @(varargin) tools.navigator.tryToGoToNextObj())

    
    fileNumberTextBox = improc2.utils.ArrayNumberTextBox(...
        gui.goToArray, tools.navigator);
    fileNumberTextBox.draw()
    set(gui.fileLabel, 'String', sprintf('File:\nof %d', tools.navigator.numberOfArrays))
    
    objectNumberTextBox = improc2.utils.ObjectNumberTextBox(...
        gui.goToObj, tools.navigator);
    objectNumberTextBox.draw()
    
    numberOfObjectsInArrayTextBox = improc2.utils.NumberOfObjectsInArrayTextBox(...
        gui.objectLabel, tools.navigator);
    numberOfObjectsInArrayTextBox.draw();
    
    
    tools.navigator.addActionAfterMoveAttempt(objectNumberTextBox, @draw)
    tools.navigator.addActionAfterMoveAttempt(fileNumberTextBox, @draw)
    tools.navigator.addActionAfterMoveAttempt(numberOfObjectsInArrayTextBox, @draw)
    
    tools.annotations.attachUIControl('isGood', gui.goodCheck)
    
    %% channel toggle switches
%      channels = improc2.thresholdGUI.findRNAChannels(tools.objectHandle);
    paramsForComposite = improc2.utils.buildTypeCheckedValuesFromStruct(...
    struct('showDapi', true, 'showTrans', false, 'showAlexa', false, 'showTmr', false, 'showCy', true, 'showNir', false, 'showGfp', false));

%     %%
%     channels = [channels 'dapi' 'trans'];
%     test = [];
%     for j = 1:length(channels)
%         name = [(channels{j}) '_color'];
%     set(gui.(name), 'CallBack', @(varargin) uisetcolor)
%     test = [test, get(gui.(name), 'Value')];
%     test
%     end
%     
    %%
    [rnaChannels, rnaProcessorClassName] = improc2.thresholdGUI.findRNAChannels(objectHandle);
    
    rnaChannelSwitch = dentist.utils.ChannelSwitchCoordinator(rnaChannels);
    
    rnaProcessorDataHolder = improc2.utils.ProcessorDataHolder(...
        objectHandle, rnaChannelSwitch, rnaProcessorClassName);
        %%
    keyboardCommandInterpreter = improc2.utils.NavigationKeyboardInterpreter(...
        tools.navigator, rnaChannelSwitch);
    set(gui.figH, 'WindowKeyPressFcn', @keyboardCommandInterpreter.keyPressCallBackFunc)
    
    
        %% rna image Holder and image/thresholdplot saturation values
    
    rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);
    saturationValuesHolder = improc2.utils.FixedContrastSettings(rnaChannelSwitch, rnaScaledImageHolder);
 
    %%
    outStruct = struct();
    outStruct.tools = tools;
    outStruct.rnaProcessorDataHolder = rnaProcessorDataHolder;
    outStruct.saturationValuesHolder = saturationValuesHolder;
    outStruct.keyboardInterpreter = keyboardCommandInterpreter;
    outStruct.paramsForComposite = paramsForComposite;
    outStruct.gui = gui;
    outStruct.channels = channels;
    outStruct.nodeName = ip.Results.nodeName;

end





