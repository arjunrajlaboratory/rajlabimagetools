classdef Grouper < handle
    
    properties (Access = private)
        groupableItems
        usedGroupNumbers
    end
    
    methods
        function p = Grouper(groupableItems)
            p.groupableItems = groupableItems;
        end
        
        
        function assignGroupsToItemsAssignedToNaN(p)
            p.storeGroupNumbersUsedByItems()
            
            for i = 1:length(p.groupableItems)
                groupNum = p.groupableItems.getGroupAssignedTo(i);
                if isnan(groupNum)
                    newGroupNum = p.getAnUnusedGroupNumber();
                    p.groupableItems.assignToGroup(i, newGroupNum);
                    p.addToStoredUsedGroupNumbers(newGroupNum);
                end
            end
        end
        
        function assignItemsToAGroup(p, indicesOfItemsToGroupTogether)
            indicesOfAllOtherItems = ...
                setdiff(1:length(p.groupableItems), indicesOfItemsToGroupTogether);
            p.storeGroupNumbersUsedByItems(indicesOfAllOtherItems)
            
            newGroupNum = p.getAnUnusedGroupNumber();
            for i = 1:length(indicesOfItemsToGroupTogether)
                indexOfItemToGroup = indicesOfItemsToGroupTogether(i);
                p.groupableItems.assignToGroup(indexOfItemToGroup, newGroupNum)
            end
            p.addToStoredUsedGroupNumbers(newGroupNum);
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
    methods (Access = private)
        
        function newGroupNum = getAnUnusedGroupNumber(p)
            candidateNewGroupNum = 1;
            while ismember(candidateNewGroupNum, p.usedGroupNumbers)
                candidateNewGroupNum = candidateNewGroupNum + 1;
            end
            newGroupNum = candidateNewGroupNum;
        end
        
        function clearStoredUsedGroupNumbers(p)
            p.usedGroupNumbers = [];
        end
        
        function addToStoredUsedGroupNumbers(p, groupNum)
            p.usedGroupNumbers = union(p.usedGroupNumbers, groupNum);
        end
        
        function storeGroupNumbersUsedByItems(p, indicesToCheck)
            if nargin < 2
                indicesToCheck = 1:length(p.groupableItems);
            end
            
            p.clearStoredUsedGroupNumbers()
            for i = indicesToCheck
                groupNum = p.groupableItems.getGroupAssignedTo(i);
                if ~isnan(groupNum)
                    p.addToStoredUsedGroupNumbers(groupNum)
                end
            end
        end
    end
    
end

