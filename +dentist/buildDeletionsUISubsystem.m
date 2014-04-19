function deletionsUISubsystem = buildDeletionsUISubsystem(resources)
    
    gui = resources.gui;
    deletionsSubsystem = resources.deletionsSubsystem;
    
    resetButton = dentist.utils.RemoveAllPolygonsButton(...
        deletionsSubsystem, gui.resetButton);
    undoButton = dentist.utils.RemovePolygonButton(...
        deletionsSubsystem, gui.undoButton);
    polygonDisplayer = dentist.utils.PolygonsDisplayer(gui.imgAx, deletionsSubsystem);
    visibilityToggleablePolygonDisplayer = dentist.utils.VisibilityToggleableDisplayer(...
        polygonDisplayer);
    visibilityToggleablePolygonDisplayer.setVisibilityAndDrawIfActive(false);
	deletionsSubsystem.addActionAfterDeletion(...
        visibilityToggleablePolygonDisplayer, @draw);
    
    deletionPolygonDrawingTool = dentist.utils.PolygonAddingMouseInterpreter(...
        deletionsSubsystem);
    
    deletionsUISubsystem = dentist.utils.DeletionsUIControlsEnabler(...
        undoButton, resetButton, visibilityToggleablePolygonDisplayer, ...
        deletionPolygonDrawingTool, gui.figH, gui.imgAx);
end

