function thresholdPlotSubsystem = buildThresholdPlotSubsystem(resources)
    
    gui = resources.gui;
    frequencyTableSource = resources.frequencyTableSource;
    thresholdsHolder = resources.thresholdsHolder;
    channelHolder = resources.channelHolder;
     
    thresholdPlotPlugin = dentist.utils.ThresholdPlotPlugin(gui.thresholdAx, ...
        thresholdsHolder, ...
        frequencyTableSource, channelHolder);
    thresholdPlotPlugin.draw();
    
    threshPlotNavigator = dentist.utils.ThresholdPlotMouseInterpreter(thresholdPlotPlugin);
    threshPlotNavigator.wireToFigureAndAxes(gui.figH, gui.thresholdAx);
    
    thresholdPlotSubsystem = thresholdPlotPlugin;
    
end

