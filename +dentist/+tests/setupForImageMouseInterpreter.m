function [axH, figH, mockViewportHolder] = setupForImageMouseInterpreter()
    figH = figure(1);
    axH = axes('Parent', figH);
    axis ij;
    set(figH, 'Colormap', gray(256))
    set(axH, 'PlotBoxAspectRatio', [1 1 1])
    img = rand(2000,2000);
    image('CData', img, 'XData', [1 2000], 'YData', [1 2000], ...
        'Parent', axH, 'CDataMapping', 'scaled', 'HitTest', 'off');
    set(axH, 'XLim', [0.5 2000.5], 'YLim', [0.5 2000.5])
    
    viewport = dentist.utils.ImageViewport(2000, 2000);
    viewport = viewport.scaleSize(0.4);
    viewport.drawBoundaryRectangle('EdgeColor', 'r', 'Parent', axH);
    
    mockViewportHolder = dentist.tests.RectangleDrawingViewportHolder(axH);
    mockViewportHolder.setViewport(viewport);
end

