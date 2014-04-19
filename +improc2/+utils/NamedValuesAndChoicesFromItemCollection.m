classdef NamedValuesAndChoicesFromItemCollection < improc2.interfaces.NamedValuesAndChoices
    
    properties (Access = private)
        itemCollectionHandle
    end
    
    properties (Dependent = true, SetAccess = private)
        itemNames
        itemClasses
    end
    
    methods
        function p = NamedValuesAndChoicesFromItemCollection(itemCollectionHandle)
            p.itemCollectionHandle = itemCollectionHandle;
        end
        function value = getValue(p, itemName)
            item = p.itemCollectionHandle.getItem(itemName);
            value = item.value;
        end
        function setValue(p, itemName, value)
            item = p.itemCollectionHandle.getItem(itemName);
            item.value = value;
            p.itemCollectionHandle.setItem(itemName, item)
        end
        function choices = getChoices(p, itemName)
            item = p.itemCollectionHandle.getItem(itemName);
            choices = item.choices;
        end
        function itemNames = get.itemNames(p)
            itemNames = p.itemCollectionHandle.itemNames;
        end
        function itemClasses = get.itemClasses(p)
            itemNames = p.itemNames;
            itemClasses = cell(size(itemNames));
            for i = 1:length(itemNames)
                item = p.itemCollectionHandle.getItem(itemNames{i});
                itemClasses{i} = class(item);
            end
        end
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Items:\n')
            improc2.utils.displayDescriptionOfNamedValuesAndChoices(p)
        end
    end
    
end

