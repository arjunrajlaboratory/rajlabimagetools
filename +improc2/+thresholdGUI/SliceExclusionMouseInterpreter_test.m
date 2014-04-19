improc2.tests.cleanupForTests;

sliceExcluder = improc2.tests.MockSliceExcluder();

figH = figure(1); axH = axes('Parent', figH); 
set(axH, 'YLim', [0 30], 'XLim', [0 1]);

x = improc2.thresholdGUI.SliceExclusionMouseInterpreter(sliceExcluder);
x.wireToFigureAndAxes(figH, axH)

title('left or right click, or drag. x axis is irrelevant')