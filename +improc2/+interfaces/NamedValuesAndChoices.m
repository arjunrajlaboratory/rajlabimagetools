classdef NamedValuesAndChoices < handle
    properties (Abstract = true, SetAccess = private)
        itemNames
        itemClasses
    end
    
    methods (Abstract = true)
        value = getValue(p, itemName)
        setValue(p, itemName, value)
        choices = getChoices(p, nameOfAFactorItem)
    end
    
    methods
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            fprintf('* Items:\n')
            itemNames = p.itemNames;
            itemClasses = p.itemClasses;
            for i = 1:length(itemNames)
                itemName = itemNames{i};
                itemClass = itemClasses{i};
                try
                    valAsString = improc2.utils.convertValueToString(...
                        p.getValue(itemName), itemClass);
                    valAsString = [': value = ', valAsString];
                catch
                    valAsString = '';
                end
                fprintf('\t%s%s \t(%s)\n', itemName, valAsString,...
                    itemClass)
            end
        end
    end
end
