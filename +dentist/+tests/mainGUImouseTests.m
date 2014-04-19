%% Test of gesture interpreter
close all; clear; clear classes;

g = dentist.createAndLayOutMainGUI;

imH = imshow(rand(2000,2000),'Parent', g.imgAx);
axes(g.imgAx)
line(2000*rand(1,10), 2000*rand(1,10), 'Marker', '.')
axes(g.thresholdAx)
line(rand(1,10), rand(1,10), 'Marker', '.')
x = dentist.utils.MultiMouseGestureInterpreter(g.figH, g.imgAx);
%% Demonstrates that you can rewire after imshow and you can still draw.
h2 = imshow(rand(2000,2000),'Parent', g.imgAx);
line(2000*rand(1,10), 2000*rand(1,10), 'Marker', '.')
x.rewire; % try to 
%% Test of mutually exclusive toggle button on main GUI

close all; clear; clear classes;

g = dentist.createAndLayOutMainGUI;
imH = imshow(rand(2000,2000),'Parent', g.imgAx);

mouseInterpreter = dentist.utils.MultiMouseGestureInterpreter(g.figH, g.imgAx);
toggler = dentist.utils.ToggleableGestureInterpreter(g.zoomButton, ...
    g.dragButton, g.drawButton, mouseInterpreter);