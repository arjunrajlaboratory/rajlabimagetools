function controls = launchBlobReviewGUI(varargin)
    
    controls = improc2.blobAnalyzer.blobReviewGUI.launchBlobReviewGUICore(varargin{:});
    controls = improc2.blobAnalyzer.blobReviewGUI.addImageWindowPlugin(controls);
    controls = improc2.blobAnalyzer.blobReviewGUI.addAnnotationsGUIPlugin(controls);
%     controls = blobReviewGUI.addSlicesViewerPlugin(controls);
%     controls = blobReviewGUI.addSliceExcluderPlugin(controls);
    controls = improc2.blobAnalyzer.blobReviewGUI.addSegmentViewerPlugin(controls);
    controls.imageWindowController.launchGUI();
    
end
