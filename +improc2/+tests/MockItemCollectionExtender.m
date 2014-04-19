classdef MockItemCollectionExtender < improc2.interfaces.ItemCollectionExtender
    
    properties (SetAccess = private)
        addedItems = struct();
    end
    
    methods
        function p = MockItemCollectionExtender()
        end
        function addItem(p, itemName, item)
            p.addedItems.(itemName) = item;
        end
        function throwErrorIfInvalidNewItemName(p, itemName)
            assert(ischar(itemName) && isvarname(itemName), ...
                'improc2:BadArguments',...
                'Item name must be useable as a matlab variable name (See isvarname)');
            assert(~ any(strcmp(itemName, fields(p.addedItems))), ...
                'improc2:ItemWithNameExists', ...
                'An item with this name already exists')
        end
    end
    
end

