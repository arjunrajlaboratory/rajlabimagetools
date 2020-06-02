function outStruct = launchBlobReviewGUICore(varargin)
    
    browsingTools = improc2.launchImageObjectBrowsingTools();
    
    
            ip = inputParser;
            ip.addParameter('nodeLabel', []);
            ip.addParameter('channel', []);
            ip.parse(varargin{:});
            nodeLabel = ip.Results.nodeLabel;
            blobChannel = ip.Results.channel;

    %%
    gui = improc2.blobAnalyzer.blobReviewGUI.layOutBlobReviewGUICore();
    set(gui.figH, 'HandleVisibility', 'callback')
    
    objectHandle = browsingTools.objectHandle;
    
    %%
    [rnaChannels, rnaProcessorClassName] = improc2.blobAnalyzer.blobReviewGUI.findRNAChannels(objectHandle);
    
    rnaChannelSwitch = dentist.utils.ChannelSwitchCoordinator(rnaChannels);
    rnaChannelSwitch.attachUIControl(gui.channelMenu);
    
    rnaProcessorDataHolder = improc2.utils.ProcessorDataHolder(...
        objectHandle, rnaChannelSwitch, rnaProcessorClassName);
    
    blobProcessorDataHolder = improc2.utils.ProcessorDataHolder(...
        objectHandle, blobChannel, nodeLabel);
    
    
    %% rna image Holder and image/thresholdplot saturation values
    
    rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);
    saturationValuesHolder = improc2.utils.FixedContrastSettings(rnaChannelSwitch, rnaScaledImageHolder);
    
%     %% thresholdPlotter
%     
%     
%     thresholdPlugin = improc2.ThresholdPlotPlugin(gui.thresholdAx, ...
%         rnaProcessorDataHolder, saturationValuesHolder);
%     thresholdPlugin.attachPlotLogYUIControl(gui.plotLogYCheck)
%     thresholdPlugin.attachAutomaticXAxisControl(gui.autoXAxisCheck)
%     thresholdPlugin.draw()
%     saturationValuesHolder.addActionAfterSettingsChange(thresholdPlugin, @draw)
%     
%     set(gui.thresholdAx, 'ButtonDownFcn', ...
%         @(varargin) improc2.utils.setThresholdBasedOnAxesPosition(gui.thresholdAx, rnaProcessorDataHolder))
%     
%     rnaProcessorDataHolder.addActionAfterSetProcessor(thresholdPlugin, @draw)
%     rnaChannelSwitch.addActionAfterChannelSwitch(thresholdPlugin, @draw)
%     browsingTools.navigator.addActionAfterMoveAttempt(thresholdPlugin, @draw)
    
    %% Has Clear Threshold plugin
%     
%     hasClearThresholdPlugin = improc2.thresholdGUI.HasClearThresholdPlugin(...
%         clearThresholdProcessorDataHolder);
%     hasClearThresholdPlugin.attachHasClearThresholdUIControl(gui.hasClearThresholdPopup);
%     
%     rnaChannelSwitch.addActionAfterChannelSwitch(hasClearThresholdPlugin, @draw)
%     browsingTools.navigator.addActionAfterMoveAttempt(hasClearThresholdPlugin, @draw)
%     
%     %% flag observed thresholds as reviewed.
%     
%     rnaChannelSwitch.addActionBeforeChannelSwitch(...
%         thresholdReviewFlagger, @flagThresholdAsReviewed)
%     browsingTools.navigator.addActionBeforeMoveAttempt(...
%         thresholdReviewFlagger, @flagThresholdAsReviewed)
    
    %% numSpotsTextBox
%     
%     numSpotsTextBox = blobReviewGUI.NumBlobsTextBox(gui.countsDisplay, blobProcessorDataHolder);
%     numSpotsTextBox.draw();
%     
%     rnaProcessorDataHolder.addActionAfterSetProcessor(numSpotsTextBox, @draw)
% %     rnaChannelSwitch.addActionAfterChannelSwitch(numSpotsTextBox, @draw)
%     browsingTools.navigator.addActionAfterMoveAttempt(numSpotsTextBox, @draw)
%     
    %% isGood checkbox
    

    
    browsingTools.annotations.attachUIControl('isGood', gui.goodCheck)
    browsingTools.annotations.attachUIControl('areBlobsGood', gui.goodBlobCheck)
    
    
    
    %% Navigation UI elements
    
    set(gui.prevObj, 'CallBack', @(varargin) browsingTools.navigator.tryToGoToPrevObj())
    set(gui.nextObj, 'CallBack', @(varargin) browsingTools.navigator.tryToGoToNextObj())
    
    fileNumberTextBox = improc2.utils.ArrayNumberTextBox(...
        gui.goToArray, browsingTools.navigator);
    fileNumberTextBox.draw()
    set(gui.fileLabel, 'String', sprintf('File:\nof %d', browsingTools.navigator.numberOfArrays))
    
    objectNumberTextBox = improc2.utils.ObjectNumberTextBox(...
        gui.goToObj, browsingTools.navigator);
    objectNumberTextBox.draw()
    
    numberOfObjectsInArrayTextBox = improc2.utils.NumberOfObjectsInArrayTextBox(...
        gui.objectLabel, browsingTools.navigator);
    numberOfObjectsInArrayTextBox.draw();
    
    
    browsingTools.navigator.addActionAfterMoveAttempt(objectNumberTextBox, @draw)
    browsingTools.navigator.addActionAfterMoveAttempt(fileNumberTextBox, @draw)
    browsingTools.navigator.addActionAfterMoveAttempt(numberOfObjectsInArrayTextBox, @draw)
    
    %% Navigation by keyboard
    
    keyboardCommandInterpreter = improc2.utils.NavigationKeyboardInterpreter(...
        browsingTools.navigator, rnaChannelSwitch);
    set(gui.figH, 'WindowKeyPressFcn', @keyboardCommandInterpreter.keyPressCallBackFunc)
    
    %% Areas where extra buttons can be put in
    
    numColumns = 1;
    minNumberOfRows = 4;
    upperAreaLayoutCalculator = ...
        improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
        numColumns, minNumberOfRows);
    upperExtensibleButtonGroup = improc2.utils.ExtensiblePushButtonGroup(...
        gui.upperFreeArea, upperAreaLayoutCalculator);
    
    numColumns = 2;
    minNumberOfRows = 2;
    lowerAreaLayoutCalculator = ...
        improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
        numColumns, minNumberOfRows);
    lowerExtensibleButtonGroup = improc2.utils.ExtensiblePushButtonGroup(...
        gui.lowerFreeArea, lowerAreaLayoutCalculator);
    
    %% Add button to set Saturation value to current image max
%     
%     lowerExtensibleButtonGroup.makeNewButton(...
%         'String', 'Use max for fixed', ...
%         'FontSize', 12, ...
%         'Tooltip', 'Use this object''s max intensity for fixed contrast mode in this channel', ...
%         'CallBack', @(varargin) saturationValuesHolder.setSaturationValue(...
%         rnaProcessorDataHolder.processorData.regionalMaxValues(end))...
%         );
    
    %% Build output
    
    outStruct = struct();
    outStruct.browsingTools = browsingTools;
    outStruct.keyboardInterpreter = keyboardCommandInterpreter;
    outStruct.rnaChannelSwitch = rnaChannelSwitch;
    outStruct.rnaProcessorDataHolder = rnaProcessorDataHolder;
    outStruct.saturationValuesHolder = saturationValuesHolder;
    outStruct.upperExtensibleButtonGroup = upperExtensibleButtonGroup;
    outStruct.lowerExtensibleButtonGroup = lowerExtensibleButtonGroup;
    outStruct.blobProcessorDataHolder = blobProcessorDataHolder;
%     outStruct.thresholdPlugin = thresholdPlugin;
    
    
end
