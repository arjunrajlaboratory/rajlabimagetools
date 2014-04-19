function addAnnotationItemsToAllObjects(annotationStruct, varargin)
    
    tools = improc2.launchImageObjectTools(varargin{:});
    
    iterator = tools.iterator;
    annotationItemAdder = tools.annotationItemAdder;
    
    newItemNames = fields(annotationStruct);
    
    iterator.goToFirstObject()
    while iterator.continueIteration;
        for i = 1:length(newItemNames)
            itemName = newItemNames{i};
            annotationItemAdder.addItem(itemName, annotationStruct.(itemName));
        end
        iterator.goToNextObject()
    end
end

