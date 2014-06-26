classdef ImageObjectArrayCollectionNavigator < handle
    
    properties (SetAccess = private, GetAccess = private)
        actionsAfterPuttingObjOnObjHolder
        actionsBeforeStoringObjFromObjHolder % untested
        actionsAfterMoveAttemptToNewArray % untested
        imageObjectArrayCollection
        objects
        needsSave = false;
        objHolder
    end
    
    properties (SetAccess = private)
        currentArrayNum;
        currentObjNum;
    end
    
    properties (Dependent = true, SetAccess = private)
        numberOfArrays
        numberOfObjectsInCurrentArray
    end
    
    methods
        function p = ImageObjectArrayCollectionNavigator(...
                imageObjectArrayCollection, objHolder)
            p.imageObjectArrayCollection = imageObjectArrayCollection;
            p.objHolder = objHolder;
            p.actionsAfterPuttingObjOnObjHolder = improc2.utils.DependencyRunner();
            p.actionsBeforeStoringObjFromObjHolder = improc2.utils.DependencyRunner();
            p.actionsAfterMoveAttemptToNewArray = improc2.utils.DependencyRunner();
            p.currentArrayNum = 0;
            foundOneObject = p.tryToGoToNextNonEmptyArray();
            assert(foundOneObject, 'improc2:NoImageObjects', ...
                'No Image Objects Found');
            p.putCurrentObjOnObjHolder();
        end
        
        function num = get.numberOfArrays(p)
            num = length(p.imageObjectArrayCollection);
        end
        
        function num = get.numberOfObjectsInCurrentArray(p)
            num = length(p.objects);
        end
        
        % untested
        function addActionAfterMovingToNewArray(p, handleToObject, funcToRunOnIt)
            p.actionsAfterMoveAttemptToNewArray.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function addActionAfterMoveAttempt(p, handleToObject, funcToRunOnIt)
            p.actionsAfterPuttingObjOnObjHolder.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        % untested
        function addActionBeforeMoveAttempt(p, handleToObject, funcToRunOnIt)
            p.actionsBeforeStoringObjFromObjHolder.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        
        function tryToGoToNextObj(p)
            p.storeObjFromObjHolder();
            
            if p.currentObjNum < length(p.objects)
                p.currentObjNum = p.currentObjNum + 1;
                triedToGoToNewArray = false;
            else
                p.saveIfNeedsSave();
                p.tryToGoToNextNonEmptyArray();
                triedToGoToNewArray = true;
            end
            p.putCurrentObjOnObjHolder()
            if triedToGoToNewArray
                p.actionsAfterMoveAttemptToNewArray.runDependencies();
            end
        end
        
        function tryToGoToPrevObj(p)
            p.storeObjFromObjHolder();
            if p.currentObjNum > 1
                p.currentObjNum = p.currentObjNum - 1;
                triedToGoToNewArray = false;
            else
                p.saveIfNeedsSave();
                prevObjectSucceeded = p.tryToGoToPrevNonEmptyArray();
                triedToGoToNewArray = true;
                if prevObjectSucceeded
                    p.currentObjNum = length(p.objects);
                end
            end
            p.putCurrentObjOnObjHolder()
            if triedToGoToNewArray
                p.actionsAfterMoveAttemptToNewArray.runDependencies();
            end
        end
        
        function tryToGoToArray(p, requestedArrayNum)
            p.storeObjFromObjHolder();
            assert(isscalar(requestedArrayNum) && ...
                isnumeric(requestedArrayNum) && mod(requestedArrayNum,1) == 0, ...
                'improc2:BadArguments', ...
                'Requested Array Number must be a scalar integer')
            requestedArrayNum = min(requestedArrayNum, length(p.imageObjectArrayCollection));
            requestedArrayNum = max(1, requestedArrayNum);
            p.saveIfNeedsSave();
            p.currentArrayNum = requestedArrayNum;
            p.loadCurrDataArrayIfNotEmpty() || ...
                p.tryToGoToNextNonEmptyArray() || ...
                p.tryToGoToPrevNonEmptyArray();
            p.currentObjNum = 1;
            p.putCurrentObjOnObjHolder()
            p.actionsAfterMoveAttemptToNewArray.runDependencies();
        end
        
        function tryToGoToObj(p, requestedObj)
            p.storeObjFromObjHolder();
            assert(isscalar(requestedObj) && isnumeric(requestedObj) ...
                && (mod(requestedObj,1) == 0) && (requestedObj > 0), ...
                'improc2:BadArguments', ...
                'Requested Obj Number must be a scalar positive integer')
            if requestedObj <= length(p.objects)
                p.currentObjNum = requestedObj;
            else
                p.currentObjNum = length(p.objects);
            end
            p.putCurrentObjOnObjHolder()
        end
        
        function saveIfNeedsSave(p)
            if p.currentArrayNum ~= 0
                p.saveObjectsArray();
            end
        end
        
        function discardUnsavedChangesAndReload(p)
            p.loadCurrDataArrayIfNotEmpty();
            p.putCurrentObjOnObjHolder()
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            fprintf('* Location:\n')
            fprintf('\tcurrentObjNum: %d\n', p.currentObjNum);
            fprintf('\tcurrentArrayNum: %d\n', p.currentArrayNum);
        end
    end
    
    methods (Access = private)
        
        function putCurrentObjOnObjHolder(p)
            p.objHolder.obj = p.objects(p.currentObjNum);
            p.actionsAfterPuttingObjOnObjHolder.runDependencies();
        end
        
        function storeObjFromObjHolder(p)
            p.actionsBeforeStoringObjFromObjHolder.runDependencies();
            p.objects(p.currentObjNum) = p.objHolder.obj;
        end
        
        function dataArrayIsNotEmpty = loadCurrDataArrayIfNotEmpty(p)
            loadedObjects = p.imageObjectArrayCollection.getObjectsArray(p.currentArrayNum);
            dataArrayIsNotEmpty = ~isempty(loadedObjects);
            if dataArrayIsNotEmpty
                % validate that these are good objects
                % using the errorIfInvalid method defined for each type of
                % object.
                for i = 1:length(loadedObjects)
                    errorIfInvalid(loadedObjects(i))
                end
                p.objects = loadedObjects;
            end
        end
        
        function saveObjectsArray(p)
            p.imageObjectArrayCollection.setObjectsArray(p.objects, p.currentArrayNum);
        end
        
        function foundANonEmptyArray = tryToGoToNextNonEmptyArray(p)
            foundANonEmptyArray = false;
            initialDataArrayNum = p.currentArrayNum;
            while p.currentArrayNum < length(p.imageObjectArrayCollection)
                p.currentArrayNum = p.currentArrayNum + 1;
                if p.loadCurrDataArrayIfNotEmpty();
                    foundANonEmptyArray = true;
                    p.currentObjNum = 1;
                    break;
                end
            end
            if ~foundANonEmptyArray
                p.currentArrayNum = initialDataArrayNum;
            end
        end
        
        function foundANonEmptyArray = tryToGoToPrevNonEmptyArray(p)
            foundANonEmptyArray = false;
            initialDataArrayNum = p.currentArrayNum;
            while p.currentArrayNum > 1
                p.currentArrayNum = p.currentArrayNum - 1;
                if p.loadCurrDataArrayIfNotEmpty();
                    foundANonEmptyArray = true;
                    p.currentObjNum = 1;
                    break;
                end
            end
            if ~foundANonEmptyArray
                p.currentArrayNum = initialDataArrayNum;
            end
        end
    end
end

