function augmentedControls = addImageWindowPlugin(thresholdGUIControls)
    
    rnaProcessorDataHolder = thresholdGUIControls.rnaProcessorDataHolder;
    rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);
    
    if isfield(thresholdGUIControls, 'viewportHolder')
        viewportHolder = thresholdGUIControls.viewportHolder;
    else
        sizeAdaptiveViewportHolder = ...
            improc2.utils.ImageSizeAdaptiveViewportHolder(rnaScaledImageHolder);
        viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
    end
    
    resources = struct();
    resources.saturationValuesHolder = thresholdGUIControls.saturationValuesHolder;
    resources.rnaScaledImageHolder = rnaScaledImageHolder;
    resources.viewportHolder = viewportHolder;
    resources.objectHandle = thresholdGUIControls.browsingTools.objectHandle;
    resources.rnaProcessorDataHolder = thresholdGUIControls.rnaProcessorDataHolder;
    resources.keyboardInterpreter = thresholdGUIControls.keyboardInterpreter;
    
    imageWindowController = improc2.thresholdGUI.ImageWindowModuleSingleton(resources);
    
    viewportHolder.addActionAfterViewportSetting(imageWindowController, @updateIfActive);
    thresholdGUIControls.rnaProcessorDataHolder.addActionAfterSetProcessor(imageWindowController, @updateIfActive)
    thresholdGUIControls.rnaChannelSwitch.addActionAfterChannelSwitch(imageWindowController, @updateIfActive)
    thresholdGUIControls.browsingTools.navigator.addActionAfterMoveAttempt(imageWindowController, @updateIfActive)
    thresholdGUIControls.saturationValuesHolder.addActionAfterSettingsChange(imageWindowController, @updateIfActive)
    
    thresholdGUIControls.upperExtensibleButtonGroup.makeNewButton('String', 'show Image', ...
        'Callback', @(varargin) imageWindowController.launchGUI());
    
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand(...
        {'r','R'}, @imageWindowController.toggleSpots)
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand(...
        {'g','G'}, @imageWindowController.toggleSegmentation)
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand(...
        {'p','P'}, @imageWindowController.toggleDapi)
    thresholdGUIControls.keyboardInterpreter.addKeyPressCommand(...
        {'t','T'}, @imageWindowController.toggleTrans)
    
    augmentedControls = thresholdGUIControls;
    augmentedControls.imageWindowController = imageWindowController;
    augmentedControls.viewportHolder = viewportHolder;
end

