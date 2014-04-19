dentist.tests.cleanupForTests;

[axH, figH, mockViewportHolder] = dentist.tests.setupForImageMouseInterpreter();

x = dentist.utils.ImageZoomingMouseInterpreter(mockViewportHolder);
x.wireToFigureAndAxes(figH, axH);
title('left/right/double click or Drag. New white boxes should appear')
