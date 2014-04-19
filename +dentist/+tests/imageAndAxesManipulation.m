%% Test of gesture interpreter
close all; clear; clear classes;

g = dentist.createAndLayOutMainGUI;

img = rand(2000,2000);
set(g.figH, 'Colormap', gray(256))
set(g.imgAx, 'PlotBoxAspectRatio', [1 1 1])
imH = image('CData', img, 'XData', [1 2000], 'YData', [1 2000], ...
    'Parent', g.imgAx, 'CDataMapping', 'scaled', 'HitTest', 'off');
%imH = imshow(img,'Parent', g.imgAx);
axes(g.imgAx)
set(g.imgAx, 'ButtonDownFcn', @(hObject,eventdata) display(gcbo))
%%
set(imH, 'XData', [1001 3000])

%%
cdata = get(imH, 'CData');
xdata = get(imH, 'XData');
clim = get(g.imgAx, 'CLim');
climmode = get(g.imgAx, 'CLimMode');