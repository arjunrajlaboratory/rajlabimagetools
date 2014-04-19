classdef TypeCheckedItemCollectionExtender < improc2.interfaces.ItemCollectionExtender
    
    properties (SetAccess = private, GetAccess = private)
        itemCollectionExtender
    end
    
    methods
        function p = TypeCheckedItemCollectionExtender(itemCollectionExtender)
            p.itemCollectionExtender = itemCollectionExtender;
        end

        function addItem(p, itemName, item)
            if ~isa(item, 'improc2.interfaces.TypeCheckedValue')
                try
                    item = improc2.makeTypeCheckedFromInput(item);
                catch err
                    if strcmp(err.identifier, 'improc2:ConvertToTypeCheckedFailed')
                        error('improc2:ConvertToTypeCheckedFailed', ...
                            ['item must be an instance of a subclass of ', ...
                            'improc2.interfaces.TypeCheckedValue\n', ...
                            'or convertible to one using improc2.makeTypeCheckedFromInput'])
                    else
                        rethrow(err)
                    end
                end
            end
            p.itemCollectionExtender.addItem(itemName, item);
        end
        
        function throwErrorIfInvalidNewItemName(p, itemName)
            p.itemCollectionExtender.throwErrorIfInvalidNewItemName(itemName)
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
end

