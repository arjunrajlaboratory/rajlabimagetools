classdef MasksImageForAllObjectsInArray < handle
    
    properties (Access = private)
        objectHandle
        navigator
    end
    
    methods
        function p = MasksImageForAllObjectsInArray(objectHandle, navigator)
            p.objectHandle = objectHandle;
            p.navigator = navigator;
        end
        
        function img = getImage(p)
            numObjs = p.navigator.numberOfObjectsInCurrentArray;
            individualImFiles = cell(1, numObjs);
            
            for i = 1:numObjs
                p.navigator.tryToGoToObj(i);
                individualImFiles{i} = p.objectHandle.getMask();
            end
            
            allMasks = cat(3, individualImFiles{:});
            img = max(allMasks, [], 3);
        end
    end
end

