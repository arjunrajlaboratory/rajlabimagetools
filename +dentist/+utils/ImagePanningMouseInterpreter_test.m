dentist.tests.cleanupForTests;

[axH, figH, mockViewportHolder] = dentist.tests.setupForImageMouseInterpreter();

x = dentist.utils.ImagePanningMouseInterpreter(mockViewportHolder);
x.wireToFigureAndAxes(figH, axH);
title('drag. white boxes will appear in the *opposite* direction')
