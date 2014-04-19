function figH = launchAnnotationsGUI(annotationsBrowser)
    
    itemNames = annotationsBrowser.itemNames;
    itemClasses = annotationsBrowser.itemClasses;
    
    gui = improc2.createGUIForTypeCheckedItems(...
        itemNames, itemClasses);
    
    for i = 1:length(itemNames)
        itemName = itemNames{i};
        annotationsBrowser.attachUIControl(itemName, gui.itemControls.(itemName));
    end
    
    figH = gui.figH;
end

