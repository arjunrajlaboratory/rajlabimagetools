function browsingTools = launchImageObjectBrowsingTools(varargin)
    
    tools = improc2.launchImageObjectTools(varargin{:});
    
    navigator = tools.navigator;
    browsingTools = struct();
    browsingTools.navigator = navigator;
    browsingTools.annotations = tools.annotations;
    browsingTools.objectHandle = tools.objectHandle;
    browsingTools.refresh = @navigator.discardUnsavedChangesAndReload;
    
    browsingTools.navigator.addActionAfterMoveAttempt(...
        browsingTools.annotations, @update);
end
