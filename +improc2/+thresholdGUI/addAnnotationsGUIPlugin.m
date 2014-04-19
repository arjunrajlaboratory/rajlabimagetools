function augmentedControls = addAnnotationsGUIPlugin(thresholdGUIControls)
    
    annotationsGUILauncher = improc2.thresholdGUI.AnnotationGUILauncher(...
        thresholdGUIControls.browsingTools.annotations);
    
    thresholdGUIControls.upperExtensibleButtonGroup.makeNewButton('String', 'Annotations', ...
        'Callback', @(varargin) annotationsGUILauncher.launchGUI());
    
    augmentedControls = thresholdGUIControls;
    augmentedControls.annotationsGUILauncher = annotationsGUILauncher;
end

