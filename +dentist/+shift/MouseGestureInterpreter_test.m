dentist.tests.cleanupForTests;

figH = figure(1); axH = axes('Parent', figH);
title('Click or drag should have no observable effect')

assert(isempty(get(axH, 'ButtonDownFcn')))

x = dentist.utils.MouseGestureInterpreter();
x.wireToFigureAndAxes(figH, axH);

assert(~isempty(get(axH, 'ButtonDownFcn')))

x.unwire()

assert(isempty(get(axH, 'ButtonDownFcn')))
