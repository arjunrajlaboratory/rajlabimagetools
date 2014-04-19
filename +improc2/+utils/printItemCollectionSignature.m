function printItemCollectionSignature(itemCollectionHandle)
    itemNames = itemCollectionHandle.itemNames;
    itemClasses = itemCollectionHandle.itemClasses;
    for i = 1:length(itemNames)
        itemName = itemNames{i};
        itemClass = itemClasses{i};
        fprintf('\t%s \t(%s)\n', itemName, itemClass)
    end 
end
