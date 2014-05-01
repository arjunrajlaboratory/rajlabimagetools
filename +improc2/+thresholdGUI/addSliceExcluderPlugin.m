function augmentedControls = addSliceExcluderPlugin(thresholdGUIControls)

    if isa(thresholdGUIControls.rnaProcessorDataHolder.processorData, 'imageProcessors.Processor')
        fprintf('Slice Excluder plugin is not available for legacy image objects\n')
        augmentedControls = thresholdGUIControls;
        return
    end
       
    resources = struct();
    resources.processorDataHolder = thresholdGUIControls.rnaProcessorDataHolder;
    resources.keyboardInterpreter = thresholdGUIControls.keyboardInterpreter;
    
    sliceExcluderPlugin = improc2.thresholdGUI.SliceExcluderGUIManager(resources);
    
    thresholdGUIControls.upperExtensibleButtonGroup.makeNewButton(...
        'String', 'Exclude Slices', ...
        'Callback', @(varargin) sliceExcluderPlugin.launchGUI());
    
    thresholdGUIControls.rnaProcessorDataHolder.addActionAfterSetProcessor(...
        sliceExcluderPlugin, @updateIfActive)
    thresholdGUIControls.rnaChannelSwitch.addActionAfterChannelSwitch(...
        sliceExcluderPlugin, @updateIfActive)
    thresholdGUIControls.browsingTools.navigator.addActionAfterMoveAttempt(...
        sliceExcluderPlugin, @updateIfActive)
    
    augmentedControls = thresholdGUIControls;
    augmentedControls.sliceExcluderPlugin = sliceExcluderPlugin;
    
end

