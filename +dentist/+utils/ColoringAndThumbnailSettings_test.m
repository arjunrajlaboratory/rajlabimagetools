dentist.tests.cleanupForTests;

scalefcn = @(x) ones(size(x));
cmap = jet(2);

channelNames = {'cy', 'tmr'};

channelHolder = dentist.utils.ChannelHolder(channelNames);

numSpotsColorTranslators = dentist.utils.makeFilledChannelArray( ...
    channelNames, ...
    @(channelName) dentist.tests.MockValueToColorTranslator(scalefcn, cmap));

thumbnailMakers = dentist.utils.makeFilledChannelArray( ...
    channelNames, @(channelName) dentist.tests.MockThumbnailMaker());

a = dentist.tests.MockDrawCountingDisplayer(false);
b = dentist.tests.MockDrawCountingDisplayer(false);

x = dentist.utils.ColoringAndThumbnailSettings(numSpotsColorTranslators, ...
    thumbnailMakers, channelHolder);
x.addActionOnSettingsChange(a, @draw)
x.addActionOnSettingsChange(b, @draw)

assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)
mcy = thumbnailMakers.getByChannelName('cy');
mtmr = thumbnailMakers.getByChannelName('tmr');

tcy = numSpotsColorTranslators.getByChannelName('cy');
ttmr = numSpotsColorTranslators.getByChannelName('tmr');

assert(mcy.timesMade == 0)
assert(all(all(tcy.storedCmap == cmap)))
x.setNumSpotsColorMap(hsv(32), 'cy')
assert(all(all(tcy.storedCmap == hsv(32))))
assert(mcy.timesMade == 1)
assert(mtmr.timesMade == 0)
assert(all(all(ttmr.storedCmap == cmap)))
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)

assert(ttmr.storedFunc(2) == 1)
x.setNumSpotsScalingFunction( @(x) x.^2 , 'tmr')
assert(ttmr.storedFunc(2) == 4)
assert(mcy.timesMade == 1)
assert(mtmr.timesMade == 1)
assert(tcy.storedFunc(2) == 1)
assert(a.timesDrawn == 2)
assert(b.timesDrawn == 2)

assert(strcmp(mtmr.prioritized, 'high'))
x.prioritizeLowExpressers('tmr')
assert(strcmp(mtmr.prioritized, 'low'))
assert(mtmr.timesMade == 2)
assert(mcy.timesMade == 1)
assert(a.timesDrawn == 3)
assert(b.timesDrawn == 3)


x.prioritizeHighExpressers('tmr')
assert(strcmp(mtmr.prioritized, 'high'))
assert(mtmr.timesMade == 3)
assert(mcy.timesMade == 1)
assert(a.timesDrawn == 4)
assert(b.timesDrawn == 4)

% Some tests of how it uses the channelHolder to determine the channel 
% if no channel is given.

channelHolder.setChannelName('cy')

assert(strcmp(mcy.prioritized, 'high'))
assert(strcmp(mtmr.prioritized, 'high'))
x.prioritizeLowExpressers()
assert(strcmp(mcy.prioritized, 'low'))
assert(strcmp(mtmr.prioritized, 'high'))
x.prioritizeHighExpressers()
assert(strcmp(mcy.prioritized, 'high'))
assert(strcmp(mtmr.prioritized, 'high'))

assert(tcy.storedFunc(2) == 1)
x.setNumSpotsScalingFunction( @(x) x.^2)
assert(tcy.storedFunc(2) == 4)

x.setNumSpotsColorMap(bone(32))
assert(all(all(tcy.storedCmap == bone(32))))
