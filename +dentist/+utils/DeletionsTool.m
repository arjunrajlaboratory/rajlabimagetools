classdef DeletionsTool < handle
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private, SetAccess = private)
        deleter
        deletionCriteriaProvider
        objectsToDrawWhenADeletionHappens = {};
    end
    
    methods
        function p = DeletionsTool(deleter, deletionCriteriaProvider)
            p.deleter = deleter;
            p.deletionCriteriaProvider = deletionCriteriaProvider;
        end
        
        function addObjectToDrawWhenADeletionHappens(p, obj)
            p.objectsToDrawWhenADeletionHappens = [...
                p.objectsToDrawWhenADeletionHappens, {obj}];
        end
        
        function applyDeletion(p)
            FUNC = p.deletionCriteriaProvider.getXYFilter();
            p.deleter.deleteByXYFilter(FUNC);
            p.drawListeners();
        end
    end
    
    methods (Access = private)
        function drawListeners(p)
           for i = 1:length(p.objectsToDrawWhenADeletionHappens)
                p.objectsToDrawWhenADeletionHappens{i}.draw();
           end
        end
    end
    
end

