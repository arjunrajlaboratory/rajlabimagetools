classdef ItemCollectionHandle < handle
    
    properties (Abstract = true, SetAccess = private)
        itemNames
    end
    
    methods (Abstract = true)
        item = getItem(p, itemName)
        setItem(p, itemName, item)
    end 
end

