classdef AnnotationsAdder < handle
    
    properties (Access = private)
        collectionOfNewItems
        valuesAndChoicesOfNewItems
        itemCollectionExtender
        namedValuesAndChoices
        objIterator
    end
    
    methods
        function p = AnnotationsAdder(itemCollectionExtender, namedValuesAndChoices, objIterator)
            p.itemCollectionExtender = itemCollectionExtender;
            p.namedValuesAndChoices = namedValuesAndChoices;
            p.collectionOfNewItems = improc2.utils.FieldsBasedItemCollectionHandle(struct());
            p.valuesAndChoicesOfNewItems = ...
                improc2.utils.NamedValuesAndChoicesFromItemCollection(p.collectionOfNewItems);
            p.objIterator = objIterator;
        end
        
        function addNewItemsToAllObjectsAndQuit(p)
            p.objIterator.goToFirstObject()
            while p.objIterator.continueIteration
                for i = 1:length(p.collectionOfNewItems.itemNames)
                    itemName = p.collectionOfNewItems.itemNames{i};
                    itemToAdd = p.collectionOfNewItems.getItem(itemName);
                    p.itemCollectionExtender.addItem(itemName, itemToAdd)
                end
                p.objIterator.goToNextObject()
            end
            delete(p)
        end
        
        function specifyNewNumericItem(p, itemName, optionalDefaultValue)
            p.itemCollectionExtender.throwErrorIfInvalidNewItemName(itemName)
            if nargin == 3
                defaultValue = optionalDefaultValue;
            else
                defaultValue = NaN;
            end
            itemToAdd = improc2.TypeCheckedNumeric(defaultValue);
            p.addItem(itemName, itemToAdd);
        end
        
        function specifyNewFactorItem(p, itemName, choices, optionalDefaultValue)
            p.itemCollectionExtender.throwErrorIfInvalidNewItemName(itemName)
            if nargin == 4
                defaultValue = optionalDefaultValue;
            else
                defaultValue = 'NA';
            end
            if ~ismember('NA', choices)
                choicesWithNA = [{'NA'}, choices(:)'];
            end
            itemToAdd = improc2.TypeCheckedFactor(choicesWithNA);
            itemToAdd.value = defaultValue;
            p.addItem(itemName, itemToAdd);
        end
        
        function specifyNewYesNoOrNAItem(p, itemName, optionalDefaultValue)
            p.itemCollectionExtender.throwErrorIfInvalidNewItemName(itemName)
            if nargin == 3
                defaultValue = optionalDefaultValue;
            else
                defaultValue = 'NA';
            end
            itemToAdd = improc2.TypeCheckedYesNoOrNA(defaultValue);
            p.addItem(itemName, itemToAdd);
        end
        
        function specifyNewStringItem(p, itemName, optionalDefaultValue)
            p.itemCollectionExtender.throwErrorIfInvalidNewItemName(itemName)
            if nargin == 3
                defaultValue = optionalDefaultValue;
            else
                defaultValue = '';
            end
            itemToAdd = improc2.TypeCheckedString(defaultValue);
            p.addItem(itemName, itemToAdd);
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Existing annotations:\n')
            improc2.utils.displayDescriptionOfNamedValuesAndChoices(...
                p.namedValuesAndChoices)
            fprintf('* Items to add:\n')
            improc2.utils.displayDescriptionOfNamedValuesAndChoices(...
                p.valuesAndChoicesOfNewItems)
        end
    end
    
    methods (Access = private)
        function addItem(p, itemName, itemToAdd)
            p.collectionOfNewItems.addItem(itemName, itemToAdd)
        end
    end
    
end

