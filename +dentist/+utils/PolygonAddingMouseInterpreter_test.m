dentist.tests.cleanupForTests;

figH = figure(1); axH = axes('Parent', figH);
set(axH, 'XLim', [0 1], 'YLim', [0 1])

mockPolygonStack = dentist.tests.MockPolygonStack();

x = dentist.utils.PolygonAddingMouseInterpreter(mockPolygonStack);
x.wireToFigureAndAxes(figH, axH)
