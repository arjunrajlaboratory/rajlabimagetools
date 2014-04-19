function namedValuesAndChoices = buildTypeCheckedValuesFromStruct(initStruct)
    
    typeCheckedItems = struct();
    itemNames = fields(initStruct);
    for i = 1:length(itemNames)
        itemName = itemNames{i};
        typeCheckedItems.(itemName) = ...
            improc2.makeTypeCheckedFromInput(initStruct.(itemName));
    end
    items = improc2.utils.FieldsBasedItemCollectionHandle(typeCheckedItems);
    namedValuesAndChoices = improc2.utils.NamedValuesAndChoicesFromItemCollection(items);
end

