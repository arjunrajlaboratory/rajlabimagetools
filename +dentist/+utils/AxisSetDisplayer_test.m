dentist.tests.cleanupForTests;

figH = figure(1);
axH = axes('Parent', figH);

viewport = dentist.utils.ImageViewport(1000,1000);
viewHolder = dentist.utils.ViewportHolder(viewport);

x = dentist.utils.AxisSetDisplayer(axH, viewHolder);
x.draw();

Xs = get(axH, 'XLim');
Ys = get(axH, 'YLim');

assert(Xs(1) == viewport.ulCornerXPosition - 0.5)
assert(Xs(2) == viewport.ulCornerXPosition + viewport.width - 0.5)
assert(Ys(1) == viewport.ulCornerYPosition - 0.5)
assert(Ys(2) == viewport.ulCornerYPosition + viewport.height - 0.5)

viewport = viewport.scaleSize(0.4);
viewport = viewport.tryToCenterAtXPosition(600);
viewport = viewport.tryToCenterAtYPosition(300);

viewHolder.setViewport(viewport)
x.draw();

Xs = get(axH, 'XLim');
Ys = get(axH, 'YLim');

assert(Xs(1) == viewport.ulCornerXPosition - 0.5)
assert(Xs(2) == viewport.ulCornerXPosition + viewport.width - 0.5)
assert(Ys(1) == viewport.ulCornerYPosition - 0.5)
assert(Ys(2) == viewport.ulCornerYPosition + viewport.height - 0.5)
