classdef Legacyimage_objectAnnotationsHandle < ...
        improc2.interfaces.ExtensibleItemCollectionHandle
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    
    properties (Dependent = true, SetAccess = private)
        itemNames
        itemClasses
    end
    
    methods
        function p = Legacyimage_objectAnnotationsHandle(imObHolder)
            p.imObHolder = imObHolder;
        end
        
        function item = getItem(p, itemName)
            p.throwErrorIfNoSuchItem(itemName)
            switch itemName
                case 'isGood'
                    item = improc2.TypeCheckedLogical(...
                        logical(p.imObHolder.obj.isGood));
                otherwise
                    item = p.imObHolder.obj.metadata.annotations.(itemName);
            end
        end
        
        function setItem(p, itemName, item)
            p.throwErrorIfNoSuchItem(itemName)
            switch itemName
                case 'isGood'
                    p.imObHolder.obj.isGood = item.value;
                otherwise
                    p.ensureAnnotationsStructExists();
                    p.imObHolder.obj.metadata.annotations.(itemName) = item;
            end
        end
        
        function throwErrorIfInvalidNewItemName(p, itemName)
            assert(ischar(itemName) && isvarname(itemName), ...
                'improc2:BadArguments',...
                'Item name must be useable as a matlab variable name (See isvarname)');
            assert(~ ismember(itemName, p.itemNames), ...
                'improc2:ItemWithNameExists', ...
                'An item with this name already exists')
        end
        
        function addItem(p, itemName, item)
            p.throwErrorIfInvalidNewItemName(itemName)
            p.ensureAnnotationsStructExists();
            p.imObHolder.obj.metadata.annotations.(itemName) = item;
        end
        
        function itemNames = get.itemNames(p)
            p.ensureAnnotationsStructExists();
            itemNames = fields(p.imObHolder.obj.metadata.annotations);
            itemNames = [{'isGood'}; itemNames];
        end
    end
    
    methods (Access = private)
        function ensureAnnotationsStructExists(p)
            if ~isfield(p.imObHolder.obj.metadata, 'annotations')
                p.imObHolder.obj.metadata.annotations = struct();
            end
        end
        function throwErrorIfNoSuchItem(p, itemName)
            assert(ischar(itemName), 'improc2:BadArguments', ...
                'item Name must be a string (see ischar)')
            assert(ismember(itemName, p.itemNames), ...
                'improc2:NoSuchItem', ...
                'No item with name: %s.', itemName)
        end
    end
end

