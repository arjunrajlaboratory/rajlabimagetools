improc2.tests.cleanupForTests;

viewport = dentist.utils.ImageViewport(10,10);
viewportHolder = dentist.utils.ViewportHolder(viewport);

x = improc2.utils.NotifyingViewportHolder(viewportHolder);

a = dentist.tests.MockDrawCountingDisplayer();
b = dentist.tests.MockDrawCountingDisplayer();

x.addActionAfterViewportSetting(a, @draw);
x.addActionAfterViewportSetting(b, @draw);
assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

vp = x.getViewport();
assert(isequal(vp, viewport))

assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

vp = vp.setWidth(5);
x.setViewport(vp);
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)

assert(isequal(x.getViewport(), vp))
assert(isequal(viewportHolder.getViewport(), vp))
