function augmentedControls = addSegmentViewerPlugin(thresholdGUIControls)

% No clue what all this viewport business is about...

%     if isfield(thresholdGUIControls, 'viewportHolder')
%         viewportHolder = thresholdGUIControls.viewportHolder;
%     else
%         rnaProcessorDataHolder = thresholdGUIControls.rnaProcessorDataHolder;
%         rnaScaledImageHolder = improc2.utils.ImageFromProcessorDataHolder(rnaProcessorDataHolder);
%         sizeAdaptiveViewportHolder = ...
%             improc2.utils.ImageSizeAdaptiveViewportHolder(rnaScaledImageHolder);
%         viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
%     end
    
    resources = struct();
    resources.browsingTools = thresholdGUIControls.browsingTools;
    
% Don't think we need any of the below any more.
%     resources.channelSwitcher = thresholdGUIControls.rnaChannelSwitch;
%     resources.viewportHolder = viewportHolder;
%     resources.objectHandle = thresholdGUIControls.browsingTools.objectHandle;
%     resources.keyboardInterpreter = thresholdGUIControls.keyboardInterpreter;

    SegmentInspectorGUIManager = improc2.thresholdGUI.SegmentInspectorGUIManager(resources);
    
    thresholdGUIControls.upperExtensibleButtonGroup.makeNewButton('String', 'View segments', ...
        'Callback', @(varargin) SegmentInspectorGUIManager.launchGUI());
    
    %viewportHolder.addActionAfterViewportSetting(SegmentInspectorGUIManager, @updateIfActive);
    thresholdGUIControls.browsingTools.navigator.addActionAfterMoveAttempt(...
        SegmentInspectorGUIManager, @updateWithNewObject)
    thresholdGUIControls.browsingTools.navigator.addActionAfterMovingToNewArray(...
        SegmentInspectorGUIManager, @updateWithNewArray)
    
%     thresholdGUIControls.keyboardInterpreter.addKeyPressCommand({'uparrow','w','W'}, ...
%         @SegmentInspectorGUIManager.goUpOneSlice)
%     thresholdGUIControls.keyboardInterpreter.addKeyPressCommand({'downarrow','s','S'}, ...
%         @SegmentInspectorGUIManager.goDownOneSlice)
    
    augmentedControls = thresholdGUIControls;
%     augmentedControls.viewportHolder = viewportHolder;
    augmentedControls.SegmentGUIController = SegmentInspectorGUIManager;
    
end

