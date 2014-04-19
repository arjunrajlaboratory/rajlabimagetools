%% Figure
dentist.tests.cleanupForTests;
fH = figure(1);
h = plot(rand(10,1), rand(10,1), 'ko');
set(gca,'Xlim',[0 1], 'Ylim', [0 1])
set(h,'HitTest','off')

s = struct();
s.rectangle = dentist.utils.RectangleDrawingInterpreter();
s.line = dentist.utils.LineDrawingInterpreter();
s.freehand = dentist.utils.FreeHandDrawingInterpreter();

x = dentist.utils.MultiMouseGestureInterpreter(fH, gca, s);
title('click and drag. Also try x.setMode(''line'') or ''freehand'' or ''rectangle'' at command line')
