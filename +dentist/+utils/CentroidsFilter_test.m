dentist.tests.cleanupForTests;

numspotsCy = [10 20 30];
numspotsTmr = [100 10 100];
numspots = dentist.utils.ChannelArray({'cy','tmr'});
numspots = numspots.setByChannelName(numspotsCy, 'cy');
numspots = numspots.setByChannelName(numspotsTmr, 'tmr');
mockSource = dentist.tests.MockCentroidsAndNumSpotsSource([], numspots);

channelNames = mockSource.channelNames;

x = dentist.utils.CentroidsFilter(channelNames);

assert(all(strcmp(x.channelNames, channelNames)));

centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [1,2,3]));

% lower bound is inclusive
x.setNumSpotsLowerBound(20, 'cy');
centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [2,3]));

x.setNumSpotsUpperBound(25, 'cy');
centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [2]));

% upper bound is inclusive
x.setNumSpotsUpperBound(30, 'cy');
centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [2,3]));

x.setToDefaults();
centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [1,2,3]));

x.setNumSpotsLowerBound(20, 'cy');
x.setNumSpotsLowerBound(20, 'tmr');
centroidsPassing = x.getPassingCentroidIndices(mockSource);
assert(all(centroidsPassing == [3]));


%% bounds coercion to impose: 0 <= lower <= upper

x.setToDefaults();
assert(x.getNumSpotsLowerBound('cy') == 0)
assert(x.getNumSpotsUpperBound('cy') == Inf)
assert(x.getNumSpotsLowerBound('tmr') == 0)
assert(x.getNumSpotsUpperBound('tmr') == Inf)

x.setNumSpotsLowerBound(-10, 'cy')
assert(x.getNumSpotsLowerBound('cy') == 0)

x.setNumSpotsLowerBound(100, 'cy')
assert(x.getNumSpotsLowerBound('cy') == 100)

x.setNumSpotsUpperBound(90, 'cy')
assert(x.getNumSpotsUpperBound('cy') == 100)

x.setNumSpotsLowerBound(200, 'cy')
assert(x.getNumSpotsLowerBound('cy') == 100)

%% GUI tests:

dentist.tests.cleanupForTests;

numspotsCy = [10 20 30];
numspotsTmr = [100 10 100];
numspots = dentist.utils.ChannelArray({'cy','tmr'});
numspots = numspots.setByChannelName(numspotsCy, 'cy');
numspots = numspots.setByChannelName(numspotsTmr, 'tmr');
mockSource = dentist.tests.MockCentroidsAndNumSpotsSource([], numspots);

channelNames = mockSource.channelNames;

gui = dentist.createAndLayOutFilterGUI(channelNames);

x = dentist.utils.CentroidsFilter(channelNames);

x.attachLowerAndUpperBoundUIControls(gui.leftNumBoxes, gui.rightNumBoxes);

fprintf('Try changing the values in the GUI or in x\n')


