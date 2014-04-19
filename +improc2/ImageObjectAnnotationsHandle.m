classdef ImageObjectAnnotationsHandle < improc2.interfaces.ExtensibleItemCollectionHandle
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    
    properties (Dependent = true, SetAccess = private)
        itemNames
        itemClasses
    end
    
    methods
        function p = ImageObjectAnnotationsHandle(imObHolder)
            p.imObHolder = imObHolder;
        end
        
        function item = getItem(p, itemName)
            p.throwErrorIfNoSuchItem(itemName)
            item = p.imObHolder.obj.annotations.(itemName);
        end
        
        function setItem(p, itemName, item)
            p.throwErrorIfNoSuchItem(itemName)
            p.imObHolder.obj.annotations.(itemName) = item;
        end
        
        function addItem(p, itemName, item)
            p.throwErrorIfInvalidNewItemName(itemName)
            p.imObHolder.obj.annotations.(itemName) = item;
        end
        
        function throwErrorIfInvalidNewItemName(p, itemName)
            assert(ischar(itemName) && isvarname(itemName), ...
                'improc2:BadArguments',...
                'Item name must be useable as a matlab variable name (See isvarname)');
            assert(~ any(strcmp(itemName, p.itemNames)), ...
                'improc2:ItemWithNameExists', ...
                'An item with this name already exists')
        end
        
        function itemNames = get.itemNames(p)
            itemNames = fields(p.imObHolder.obj.annotations);
        end
    end
    
    methods (Access = private)
        function throwErrorIfNoSuchItem(p, itemName)
            assert(ischar(itemName), 'improc2:BadArguments', ...
                'item Name must be a string (see ischar)')
            assert(isfield(p.imObHolder.obj.annotations, itemName), ...
                'improc2:NoSuchItem', ...
                'No item with name: %s.', itemName)
        end
    end
end

