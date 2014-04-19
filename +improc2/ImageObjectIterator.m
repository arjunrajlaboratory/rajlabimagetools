classdef ImageObjectIterator < handle
    %UNTITLED23 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        imObjNavigator
        mostRecentArrayNum
        mostRecentObjNum
    end
    
    properties (SetAccess = private)
        continueIteration
    end
    
    methods
        function p = ImageObjectIterator(imObjNavigator)
            p.imObjNavigator = imObjNavigator;
            p.updateMostRecentAddress();
            p.continueIteration = true;
        end
        
        function goToFirstObject(p)
            p.imObjNavigator.tryToGoToArray(1);
            p.imObjNavigator.tryToGoToObj(1);
            p.updateMostRecentAddress();
            p.continueIteration = true;
        end
        
        function goToNextObject(p)
            p.imObjNavigator.tryToGoToNextObj();
            newAddressIsSameAsPrevious = ...
                (p.imObjNavigator.currentArrayNum == p.mostRecentArrayNum) && ...
                (p.imObjNavigator.currentObjNum == p.mostRecentObjNum);
            p.continueIteration = ~ newAddressIsSameAsPrevious;
            p.updateMostRecentAddress();
        end
        
        function locationStr = getLocationDescription(p)
            locationStr = sprintf('Array: %d, Obj: %d', ...
                p.imObjNavigator.currentArrayNum, p.imObjNavigator.currentObjNum);
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        function updateMostRecentAddress(p)
            p.mostRecentArrayNum = p.imObjNavigator.currentArrayNum;
            p.mostRecentObjNum = p.imObjNavigator.currentObjNum;
        end
    end
    
end

