classdef GroupableItems < handle

    methods (Abstract = true)
        groupNumberAssignedToItemOrNaN = getGroupAssignedTo(p, itemIndex);
        assignToGroup(p, itemIndex, groupNumber);
        numberOfItems = length(p);
    end
end

