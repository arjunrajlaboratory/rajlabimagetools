classdef ItemCollectionExtender < handle
    
    properties
    end
    
    methods (Abstract = true)
        addItem(p, itemName, item)
        throwErrorIfInvalidNewItemName(p, itemName)
    end
end

