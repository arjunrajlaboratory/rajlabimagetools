classdef MockGroupableItems < improc2.interfaces.GroupableItems
    
    properties (SetAccess = private)
        groupNumbersArray
    end
    
    methods
        function p = MockGroupableItems(initialGroupNumbersArray)
            p.groupNumbersArray = initialGroupNumbersArray;
        end
        function groupNumberAssignedToItem = getGroupAssignedTo(p, itemIndex)
            groupNumberAssignedToItem = p.groupNumbersArray(itemIndex);
        end
        function assignToGroup(p, itemIndex, groupNumber)
           p.groupNumbersArray(itemIndex) = groupNumber; 
        end
        function numberOfItems = length(p)
            numberOfItems = length(p.groupNumbersArray);
        end
    end
    
end

