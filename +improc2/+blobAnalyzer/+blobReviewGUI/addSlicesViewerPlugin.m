function augmentedControls = addSlicesViewerPlugin(thresholdGUIControls)
    
    if isfield(thresholdGUIControls, 'viewportHolder')
        viewportHolder = thresholdGUIControls.viewportHolder;
    else
        rnaProcessorDataHolder = thresholdGUIControls.rnaProcessorDataHolder;
        rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);
        sizeAdaptiveViewportHolder = ...
            improc2.utils.ImageSizeAdaptiveViewportHolder(rnaScaledImageHolder);
        viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
    end
    
    resources = struct();
    resources.channelSwitcher = thresholdGUIControls.rnaChannelSwitch;
    resources.viewportHolder = viewportHolder;
    resources.objectHandle = thresholdGUIControls.browsingTools.objectHandle;
    resources.keyboardInterpreter = thresholdGUIControls.keyboardInterpreter;

    sliceGUIManager = improc2.thresholdGUI.SliceInspectorGUIManager(resources);
    
    thresholdGUIControls.upperExtensibleButtonGroup.makeNewButton('String', 'View slices', ...
        'Callback', @(varargin) sliceGUIManager.launchGUI());
    
    viewportHolder.addActionAfterViewportSetting(sliceGUIManager, @updateIfActive);
    thresholdGUIControls.rnaChannelSwitch.addActionAfterChannelSwitch(...
        sliceGUIManager, @updateIfActive)
    thresholdGUIControls.browsingTools.navigator.addActionAfterMoveAttempt(...
        sliceGUIManager, @updateIfActive)
    
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand({'uparrow','w','W'}, ...
        @sliceGUIManager.goUpOneSlice)
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand({'downarrow','s','S'}, ...
        @sliceGUIManager.goDownOneSlice)
    
    augmentedControls = thresholdGUIControls;
    augmentedControls.viewportHolder = viewportHolder;
    augmentedControls.slicesGUIController = sliceGUIManager;
    
end

