dentist.tests.cleanupForTests;

[axH, figH, mockViewportHolder] = dentist.tests.setupForThumbnailMouseInterpreter();

x = dentist.utils.ThumbnailPanningMouseInterpreter(mockViewportHolder);
x.wireToFigureAndAxes(figH, axH);
title('drag. white boxes will reappear in the *same* direction')
