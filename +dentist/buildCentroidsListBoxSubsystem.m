function listBoxSubsystem = buildCentroidsListBoxSubsystem(resources, configurations )
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    gui = resources.gui;
    spotsAndCentroids = resources.spotsAndCentroids;
    channelHolder = resources.channelHolder;
    viewportHolder = resources.viewportHolder;
    
    sizeOfViewportWhenFocusedOnCentroid = ...
        configurations.sizeOfViewportWhenFocusedOnCentroid;
    
    selectionResponder = dentist.utils.FocuserOfViewportOnSelectedCentroid(...
        spotsAndCentroids, viewportHolder, sizeOfViewportWhenFocusedOnCentroid);
    
    listBoxController = dentist.utils.CentroidListBoxController(...
        gui.centList, selectionResponder, ...
        spotsAndCentroids, channelHolder);
    centroidsFilter = dentist.utils.CentroidsFilter(spotsAndCentroids.channelNames);
    listBoxController.attachCentroidsFilter(centroidsFilter);
    listBoxController.attachUseOrIgnoreFilterUIControl(gui.filterCheckBox);
    
    listBoxSubsystem = dentist.CentroidsListBoxSubsystem(listBoxController, centroidsFilter);
    listBoxSubsystem.activateLaunchFilterBoundsGUIButton(gui.filterButton);
    
end

