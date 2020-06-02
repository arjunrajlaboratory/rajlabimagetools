function augmentedControls = displayImages(manualSpotGUIControls)
    
    rnaProcessorDataHolder = manualSpotGUIControls.rnaProcessorDataHolder;
    rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);

        sizeAdaptiveViewportHolder = ...
            improc2.utils.ImageSizeAdaptiveViewportHolder(rnaScaledImageHolder);
        viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
    
    resources = struct();
    resources.saturationValuesHolder = manualSpotGUIControls.saturationValuesHolder;
    resources.rnaScaledImageHolder = rnaScaledImageHolder;
    resources.viewportHolder = viewportHolder;
    resources.objectHandle = manualSpotGUIControls.tools.objectHandle;
    resources.navigator = manualSpotGUIControls.tools.navigator;
    resources.rnaProcessorDataHolder = manualSpotGUIControls.rnaProcessorDataHolder;
    resources.keyboardInterpreter = manualSpotGUIControls.keyboardInterpreter;
    resources.paramsForComposite = manualSpotGUIControls.paramsForComposite;
    resources.gui = manualSpotGUIControls.gui;
    resources.channels = manualSpotGUIControls.channels;    
    resources.nodeName = manualSpotGUIControls.nodeName;    
    
    imageWindowController = improc2.txnSites3.ImageWindowModuleSingleton(resources);
    
    viewportHolder.addActionAfterViewportSetting(imageWindowController, @updateIfActive);
    manualSpotGUIControls.rnaProcessorDataHolder.addActionAfterSetProcessor(imageWindowController, @updateIfActive)
    manualSpotGUIControls.tools.navigator.addActionAfterMoveAttempt(imageWindowController, @updateIfActive)
    manualSpotGUIControls.saturationValuesHolder.addActionAfterSettingsChange(imageWindowController, @updateIfActive)
    

%     manualSpotGUIControls.keyboardInterpreter.addKeyPressCommand(...
%         {'r','R'}, @imageWindowController.toggleSpots)

    augmentedControls = manualSpotGUIControls;
    augmentedControls.imageWindowController = imageWindowController;
    augmentedControls.viewportHolder = viewportHolder;
end

