dentist.tests.cleanupForTests;

channels = {'alexa', 'cy', 'nir'};
Hs = dentist.createAndLayOutFilterGUI(channels);
assert(ishandle(Hs.figH))
assert(all(strcmp(Hs.leftNumBoxes.channelNames, channels)))
assert(all(strcmp(Hs.rightNumBoxes.channelNames, channels)))
for channelName = channels
    assert(ishandle(Hs.leftNumBoxes.getByChannelName(channelName)))
    assert(ishandle(Hs.rightNumBoxes.getByChannelName(channelName)))
end
assert(ishandle(Hs.applyFilter))
