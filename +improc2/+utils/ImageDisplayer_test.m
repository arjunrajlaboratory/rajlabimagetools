improc2.tests.cleanupForTests;

figH = figure(1);axH = axes('Parent', figH);

im = rand(10,10);
rgbIm = cat(3, im, 0.2*im, 0.5*im);
viewport = dentist.utils.ImageViewport(10, 10);
viewportHolder = dentist.utils.ViewportHolder(viewport);

imHolder = improc2.tests.MockImageHolder(rgbIm);

x = improc2.utils.ImageDisplayer(axH, imHolder, viewportHolder);
x.draw()


assert(~isempty(get(axH, 'Children')))
assert(all(get(axH, 'XLim') == [0.5, 10.5]))
assert(all(get(axH, 'YLim') == [0.5, 10.5]))

x.deactivate()
assert(isempty(get(axH, 'Children')))

viewport = viewport.setWidth(4);
viewport = viewport.setHeight(6);
viewportHolder.setViewport(viewport);

x.draw()
assert(all(get(axH, 'XLim') == [3.5, 7.5]))
assert(all(get(axH, 'YLim') == [2.5, 8.5]))
