function controls = launchThresholdGUI(varargin)
    
    controls = improc2.thresholdGUI.launchThresholdGUICore(varargin{:});
    controls = improc2.thresholdGUI.addImageWindowPlugin(controls);
    controls = improc2.thresholdGUI.addAnnotationsGUIPlugin(controls);
    controls = improc2.thresholdGUI.addSlicesViewerPlugin(controls);
    controls = improc2.thresholdGUI.addSliceExcluderPlugin(controls);
    controls.imageWindowController.launchGUI();
    
end
