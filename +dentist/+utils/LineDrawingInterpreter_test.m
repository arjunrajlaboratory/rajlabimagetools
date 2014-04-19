%% Class that interprets mouse drags as drawing a single line segment
% Try to click and drag on the plot that shows up.

dentist.tests.cleanupForTests;
fH = figure(1);
h = plot(rand(10,1), rand(10,1), 'ko');
set(gca,'Xlim',[0 1], 'Ylim', [0 1])
set(h,'HitTest','off')

x = dentist.utils.LineDrawingInterpreter();
x.wireToFigureAndAxes(fH, gca);
