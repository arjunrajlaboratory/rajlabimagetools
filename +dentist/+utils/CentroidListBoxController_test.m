dentist.tests.cleanupForTests;

[viewport, mockSpotsAndCentroids] = dentist.tests.setupForCentroidsAndNumSpots();

figH = figure(1);

listBoxH = uicontrol('Parent', figH, 'Style', 'listbox',...
    'Units', 'normalized', 'Position', [0.1, 0.1, 0.5, 0.8]);

selectionResponder = dentist.tests.MockCentroidSelectionResponder(mockSpotsAndCentroids);

channelHolder = dentist.utils.ChannelHolder('tmr');

x = dentist.utils.CentroidListBoxController(listBoxH, selectionResponder, ...
    mockSpotsAndCentroids, channelHolder);

%% applying a filter:

centroidsFilter = dentist.utils.CentroidsFilter(mockSpotsAndCentroids.channelNames);

x.attachCentroidsFilter(centroidsFilter);
x.setToUseFilter();

centroidsFilter.setNumSpotsLowerBound(50, 'cy');
x.draw();
centroidsFilter.setNumSpotsUpperBound(50, 'tmr');
x.draw();
maxCy = max(mockSpotsAndCentroids.getNumSpotsForCentroids('cy'));
centroidsFilter.setNumSpotsLowerBound(maxCy+1, 'cy');
x.draw();

%% un-apply filter

x.setToIgnoreFilter();

%% ignore or not ignore checkbox

centroidsFilter.setNumSpotsLowerBound(maxCy+1, 'tmr');
x.setToUseFilter();

useOrIgnoreFilterUI = uicontrol('Parent', figH, 'Style', 'checkbox', ...
    'Units', 'normalized', 'Position', [0.6, 0.1, 0.3, 0.1], ...
    'String', 'filter');

x.attachUseOrIgnoreFilterUIControl(useOrIgnoreFilterUI);
