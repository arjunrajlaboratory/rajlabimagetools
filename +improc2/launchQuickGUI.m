function launchQuickGUI(constructorThatNeedsAnObjectHolder, structOrFunc, varargin)
    
    if nargin < 2
        structOrFunc = struct(); 
    end
    if ~isstruct(structOrFunc)
        structOrFunc = struct('actionToInitializeAndUpdate', @draw);
    end
    if isstruct(structOrFunc)
       if isfield(structOrFunc, 'collection')
           collection = structOrFunc.collection;
       else
           dataFiles = improc2.utils.ImageObjectDataFiles();
           collection = improc2.utils.FileBasedImageObjectArrayCollection(dataFiles);
       end
       if   isfield(structOrFunc, 'actionToInitializeAndUpdate')
            actionToInitializeAndUpdate = structOrFunc.actionToInitializeAndUpdate; 
       else
            actionToInitializeAndUpdate = @draw;
       end    
    end
    
    additionalArgumentsToConstructor = varargin;
    
    
    objHolder = improc2.utils.ObjectHolder();
    navigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);
    
    userObject = constructorThatNeedsAnObjectHolder(objHolder, additionalArgumentsToConstructor{:});
    navigator.addActionAfterMoveAttempt(userObject, actionToInitializeAndUpdate);
    
    actionToInitializeAndUpdate(userObject)
    improc2.NavigatorGUI(navigator);
   
end

