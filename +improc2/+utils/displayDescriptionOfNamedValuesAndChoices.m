function displayDescriptionOfNamedValuesAndChoices(namedValuesAndChoices)
    
    itemNames = namedValuesAndChoices.itemNames;
    itemClasses = namedValuesAndChoices.itemClasses;
    
    for i = 1:length(itemNames)
        itemName = itemNames{i};
        itemClass = itemClasses{i};
        
        value = namedValuesAndChoices.getValue(itemName);
        valueAsString = improc2.utils.convertValueToString(value, itemClass);
        choices = namedValuesAndChoices.getChoices(itemName);
        choicesAsString = improc2.utils.convertChoicesToString(choices, itemClass);
        fprintf('\t%s: %s \tchoices = {%s}\n', itemName, ...
            valueAsString, ...
            choicesAsString)
    end
end

