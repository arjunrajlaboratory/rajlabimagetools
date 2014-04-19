dentist.tests.cleanupForTests;

lev1 = dentist.tests.MockDisplayer();
lev2 = dentist.tests.MockDisplayer();
lev3 = dentist.tests.MockDisplayer();

viewport = dentist.utils.ImageViewport(2000, 2000);
viewportHolder = dentist.utils.ViewportHolder(viewport);

x = dentist.utils.MultiZoomLevelImageDisplayer(viewportHolder, [300, 1000],...
    lev1, lev2, lev3);

assert(~lev1.isDrawn && ~lev2.isDrawn && ~lev3.isDrawn)


viewport = viewportHolder.getViewport();
viewport = viewport.setWidth(1500);
viewport = viewport.setHeight(1500);
viewportHolder.setViewport(viewport);

x.draw();
assert(~lev1.isDrawn && ~lev2.isDrawn && lev3.isDrawn)

viewport = viewportHolder.getViewport();
viewport = viewport.setWidth(700);
viewport = viewport.setHeight(700);
viewportHolder.setViewport(viewport);

x.draw();
assert(~lev1.isDrawn && lev2.isDrawn && ~lev3.isDrawn)

viewport = viewportHolder.getViewport();
viewport = viewport.setWidth(200);
viewport = viewport.setHeight(200);
viewportHolder.setViewport(viewport);

x.draw();
assert(lev1.isDrawn && ~lev2.isDrawn && ~lev3.isDrawn)

x.deactivate();
assert(~lev1.isDrawn && ~lev2.isDrawn && ~lev3.isDrawn)

%% Still works if just one displayer

solo = dentist.tests.MockDisplayer();

viewport = dentist.utils.ImageViewport(2000, 2000);
viewportHolder = dentist.utils.ViewportHolder(viewport);

y = dentist.utils.MultiZoomLevelImageDisplayer(viewportHolder, [], solo);


assert(~solo.isDrawn)
y.draw();
assert(solo.isDrawn);
