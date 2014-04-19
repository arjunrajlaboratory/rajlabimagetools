classdef FieldsBasedItemCollectionHandle < improc2.interfaces.ExtensibleItemCollectionHandle
    
    properties (Access = private)
        items
    end
    
    properties (Dependent = true, SetAccess = private)
        itemNames
    end
    
    methods
        function p = FieldsBasedItemCollectionHandle(items)
            p.items = items;
        end
        
        function item = getItem(p, itemName)
            p.throwErrorIfNoSuchItem(itemName)
            item = p.items.(itemName);
        end
        
        function setItem(p, itemName, item)
            p.throwErrorIfNoSuchItem(itemName)
            p.items.(itemName) = item;
        end
        
        function itemNames = get.itemNames(p)
            itemNames = fields(p.items);
        end
        
        function addItem(p, itemName, item)
            p.throwErrorIfInvalidNewItemName(itemName)
            p.items.(itemName) = item;
        end
        
        function throwErrorIfInvalidNewItemName(p, itemName)
            assert(ischar(itemName) && isvarname(itemName), ...
                'improc2:BadArguments',...
                'Item name must be useable as a matlab variable name (See isvarname)');
            assert(~ any(strcmp(itemName, p.itemNames)), ...
                'improc2:ItemWithNameExists', ...
                'An item with this name already exists')
        end
    end
    
    methods (Access = private)
        function throwErrorIfNoSuchItem(p, itemName)
            assert(ischar(itemName), 'improc2:BadArguments', ...
                'item Name must be a string (see ischar)')
            assert(isfield(p.items, itemName), ...
                'improc2:NoSuchItem', ...
                'No item with name: %s.', itemName)
        end
    end
end

