classdef UISynchronizedNamedValuesAndChoices < improc2.interfaces.NamedValuesAndChoices
    
    properties (SetAccess = private, GetAccess = private)
        namedValuesAndChoices
        UIsynchronizers = struct();
        actionsAfterSettingAnyValue;
    end
    
    properties (Dependent = true, SetAccess = private)
        itemNames
        itemClasses
    end
    
    methods
        function p = UISynchronizedNamedValuesAndChoices(namedValuesAndChoices)
            p.namedValuesAndChoices = namedValuesAndChoices;
            p.actionsAfterSettingAnyValue = improc2.utils.DependencyRunner();
        end
        
        function itemNames = get.itemNames(p)
            itemNames = p.namedValuesAndChoices.itemNames;
        end
        
        function itemClasses = get.itemClasses(p)
            itemClasses = p.namedValuesAndChoices.itemClasses;
        end
        
        function value = getValue(p, itemName)
            value = p.namedValuesAndChoices.getValue(itemName);
        end
        
        function setValue(p, itemName, value)
            p.namedValuesAndChoices.setValue(itemName, value);
            p.updateUIforItem(itemName)
            p.actionsAfterSettingAnyValue.runDependencies();
        end
        
        function choices = getChoices(p, nameOfAFactorItem)
            choices = p.namedValuesAndChoices.getChoices(nameOfAFactorItem);
        end
        
        function addActionAfterSettingAnyValue(p, handleToObject, funcToRunOnIt)
            p.actionsAfterSettingAnyValue.registerDependency(...
                handleToObject, funcToRunOnIt)
        end
        
        function attachUIControl(p, itemName, handleToUIControl)
            p.throwErrorIfNoSuchItem(itemName);
            interactiveValue = p.makeInteractiveValue(itemName, handleToUIControl);
            p.ensureItemHasSynchronizer(itemName);
            p.UIsynchronizers.(itemName).registerDependency(interactiveValue, @update);
        end
        
        function update(p)
            syncedItems = fields(p.UIsynchronizers);
            for i = 1:length(syncedItems)
                itemName = syncedItems{i};
                p.UIsynchronizers.(itemName).runDependencies();
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Items:\n')
            improc2.utils.displayDescriptionOfNamedValuesAndChoices(p)
        end
    end
    
    methods (Access = private)
        
        function className = getItemClass(p, itemName)
            className = p.itemClasses{find(strcmp(itemName, p.itemNames))};
        end
        
        function ensureItemHasSynchronizer(p, itemName)
            if ~isfield(p.UIsynchronizers, itemName)
                p.UIsynchronizers.(itemName) = improc2.utils.DependencyRunner();
            end
        end
        
        function newInteractive = makeInteractiveValue(p, itemName, uihandle)
            itemClass = p.getItemClass(itemName);
            switch itemClass
                case 'improc2.TypeCheckedLogical'
                    newInteractive = improc2.InteractiveLogical(itemName, p, uihandle);
                case {'improc2.TypeCheckedFactor', 'improc2.TypeCheckedYesNoOrNA'}
                    newInteractive = improc2.InteractiveFactor(itemName, p, uihandle);
                case 'improc2.TypeCheckedNumeric'
                    newInteractive = improc2.InteractiveNumeric(itemName, p, uihandle);
                case 'improc2.TypeCheckedString'
                    newInteractive = improc2.InteractiveString(itemName, p, uihandle);
                otherwise
                    error(['can only make interactive for type-checked ' ...
                        'logical, factor, numeric or string'])
            end
        end
        
        function updateUIforItem(p, itemName)
            if isfield(p.UIsynchronizers, itemName)
                p.UIsynchronizers.(itemName).runDependencies();
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

