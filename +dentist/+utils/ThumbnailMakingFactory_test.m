dentist.tests.cleanupForTests;

thumbnailMakers = dentist.utils.makeFilledChannelArray(...
    {'cy','tmr'}, @(chanName) dentist.tests.MockThumbnailMaker());

x = dentist.utils.ThumbnailMakingFactory(thumbnailMakers);

thumbnailMakers.applyForEachChannel(@(t) assert(t.timesMade == 0))
x.makeAllThumbnails()
thumbnailMakers.applyForEachChannel(@(t) assert(t.timesMade == 1))

x.setThumbnailWidthAndHeight(34, 45)
thumbnailMakers.applyForEachChannel(@(t) assert(t.thumbnailWidth == 34))
thumbnailMakers.applyForEachChannel(@(t) assert(t.thumbnailHeight == 45))

x.setPixelExpansionSize(351)
thumbnailMakers.applyForEachChannel(@(t) assert(t.pixelExpansionSize == 351))

a = dentist.tests.MockDrawCountingDisplayer(false);
b = dentist.tests.MockDrawCountingDisplayer(false);

x.addActionAfterMakingThumbnails(a, @draw)
x.addActionAfterMakingThumbnails(b, @draw)
assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)
x.makeAllThumbnails()
thumbnailMakers.applyForEachChannel(@(t) assert(t.timesMade == 2))
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)