classdef MockAnnotationsHandle < improc2.interfaces.NamedValuesAndChoices
    
    properties (SetAccess = private, GetAccess = private)
        items
    end
    
    properties (SetAccess = private)
        itemNames
        itemClasses
    end
        
    methods
        function p = MockAnnotationsHandle(initStruct)
            p.items = initStruct;
            p.itemNames = fields(initStruct);
            p.itemClasses = cellfun(@class, struct2cell(initStruct), ...
                'UniformOutput', false);
        end
        
        function value = getValue(p, itemName)
            value = p.items.(itemName).value;
        end
        
        function setValue(p, itemName, value)
            p.items.(itemName).value = value;
        end
        
        function choices = getChoices(p, itemName)
            choices = p.items.(itemName).choices;
        end
    end
    
end

