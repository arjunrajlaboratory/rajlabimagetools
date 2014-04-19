classdef ImageObjectsGroupings < handle
    
    properties (Access = private)
        imObAnnotations
        navigator
        nameOfGroupAnnotation
    end
    
    methods
        function p = ImageObjectsGroupings(navigator, imObAnnotations, nameOfGroupAnnotation)
            if nargin < 3
                nameOfGroupAnnotation = 'group';
            end
            p.navigator = navigator;
            p.imObAnnotations = imObAnnotations;
            p.nameOfGroupAnnotation = nameOfGroupAnnotation;
        end
        
        function groupNumberAssignedToItemOrNaN = getGroupAssignedTo(p, objIndex)
            p.moveToObjectAtIndex(objIndex)
            groupNumberAssignedToItemOrNaN = p.imObAnnotations.getValue(p.nameOfGroupAnnotation);
        end
        function assignToGroup(p, objIndex, groupNumber)
            p.moveToObjectAtIndex(objIndex)
            p.imObAnnotations.setValue(p.nameOfGroupAnnotation, groupNumber)
        end
        function numberOfObjs = length(p)
            numberOfObjs = p.navigator.numberOfObjectsInCurrentArray;
        end
    end
    
    methods (Access = private)
        function moveToObjectAtIndex(p, objectIndex)
            objectIndexPriorToMove = p.navigator.currentObjNum;
            p.navigator.tryToGoToObj(objectIndex)
            if p.navigator.currentObjNum == objectIndex
                return;
            else
                p.navigator.tryToGoToObj(objectIndexPriorToMove)
                error('Could not move to requested object. Stayed at old')
            end
        end
    end
end

