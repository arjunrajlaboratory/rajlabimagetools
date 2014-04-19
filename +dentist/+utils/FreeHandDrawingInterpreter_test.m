%% Class that interprets mouse input in a manner similar to imfreehand
% Try to click and draw a shape on the plot that shows up
dentist.tests.cleanupForTests;
fH = figure(1);
h = plot(rand(10,1), rand(10,1), 'ko');
set(gca,'Xlim',[0 1], 'Ylim', [0 1])
set(h,'HitTest','off')

x = dentist.utils.FreeHandDrawingInterpreter();
x.wireToFigureAndAxes(fH, gca);
