improc2.tests.cleanupForTests;

figH = figure(1); axH = axes('Parent', figH);

mask = false(10, 10);
mask(4:7, 3:5) = true;
mask(5:6, 6) = true;


maskHolder = improc2.tests.MockMaskHolder(mask);

x = improc2.utils.MaskDisplayer(axH, maskHolder);
x.draw()
assert(~isempty(get(axH, 'Children')))
x.deactivate()
assert(isempty(get(axH, 'Children')))
imshow(mask, 'Parent', axH, 'InitialMagnification', 'fit');
x.draw()
