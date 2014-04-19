%% Class that interprets mouse drags as rectangle drawing.
% Try to click and drag on the plot that shows up.

dentist.tests.cleanupForTests;
fH = figure(1);
h = plot(rand(10,1), rand(10,1), 'ko');
set(gca,'Xlim',[-0.2 1], 'Ylim', [-0.2 1])
set(h,'HitTest','off')

x = dentist.utils.RectangleDrawingInterpreter();
x.wireToFigureAndAxes(fH, gca);
