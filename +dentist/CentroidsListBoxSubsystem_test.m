dentist.tests.cleanupForTests;

[viewport, mockSpotsAndCentroids] = dentist.tests.setupForCentroidsAndNumSpots();

figH = figure(1);

listBoxH = uicontrol('Parent', figH, 'Style', 'listbox',...
    'Units', 'normalized', 'Position', [0.1, 0.1, 0.5, 0.8]);
useOrIgnoreFilterUI = uicontrol('Parent', figH, 'Style', 'checkbox', ...
    'Units', 'normalized', 'Position', [0.6, 0.1, 0.3, 0.1], ...
    'String', 'filter');
launchFilterGUIUI = uicontrol('Parent', figH, 'Style', 'pushbutton', ...
    'Units', 'normalized', 'Position', [0.6, 0.5, 0.3, 0.2], ...
    'String', 'Filter GUI');

channelHolder = dentist.utils.ChannelHolder('tmr');

selectionResponder = dentist.tests.MockCentroidSelectionResponder(mockSpotsAndCentroids);
listBoxController = dentist.utils.CentroidListBoxController(listBoxH, selectionResponder, ...
    mockSpotsAndCentroids, channelHolder);
centroidsFilter = dentist.utils.CentroidsFilter(mockSpotsAndCentroids.channelNames);
listBoxController.attachCentroidsFilter(centroidsFilter);
listBoxController.attachUseOrIgnoreFilterUIControl(useOrIgnoreFilterUI);

x = dentist.CentroidsListBoxSubsystem(listBoxController, centroidsFilter);
x.activateLaunchFilterBoundsGUIButton(launchFilterGUIUI);
x.draw();
