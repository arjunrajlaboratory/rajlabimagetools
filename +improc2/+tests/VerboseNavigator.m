classdef VerboseNavigator < handle
    properties (Access = private)
        navigator
    end
    
    properties (Dependent = true, SetAccess = private)
        currentArrayNum;
        currentObjNum;
        numberOfArrays
        numberOfObjectsInCurrentArray
    end
    
    methods
        function p = VerboseNavigator(navigator)
            p.navigator = navigator;
        end
        function tryToGoToNextObj(p)
            p.navigator.tryToGoToNextObj();
            p.printLocation()
        end
        function tryToGoToPrevObj(p)
            p.navigator.tryToGoToNextObj();
            p.printLocation()
        end
        function tryToGoToArray(p, requestedArrayNum)
            p.navigator.tryToGoToArray(requestedArrayNum)
            p.printLocation()
        end
        function tryToGoToObj(p, requestedObj)
            p.navigator.tryToGoToObj(requestedObj)
            p.printLocation()
        end
        function num = get.currentArrayNum(p)
            num = p.navigator.currentArrayNum;
        end
        function num = get.currentObjNum(p)
            num = p.navigator.currentObjNum;
        end
        function num = get.numberOfArrays(p)
            num = p.navigator.numberOfArrays;
        end
        function num = get.numberOfObjectsInCurrentArray(p)
            num = p.navigator.numberOfObjectsInCurrentArray;
        end
    end
    
    methods (Access = private)
        function printLocation(p)
            fprintf('At Array: %d, Obj: %d\n', p.currentArrayNum, p.currentObjNum)
        end
    end
end

