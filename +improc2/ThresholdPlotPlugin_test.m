improc2.tests.cleanupForTests;

regMaxVals = [1, 1, 3, 4, 6];
threshold = 5;
fakeProc = struct();
fakeProc.regionalMaxValues = regMaxVals;
fakeProc.threshold = threshold;
fakeProc.hasClearThreshold = 'yes';
fakeProc.getNumSpots = @() sum(regMaxVals > threshold); 

procHolder = improc2.tests.MockProcessorDataHolder(fakeProc);

figH = figure(1); axH = axes('Parent', figH);

satValSource = improc2.tests.MockSaturationValuesSource(10);

x = improc2.ThresholdPlotPlugin(axH, procHolder, satValSource);

x.draw()

checkLogY = uicontrol('Style', 'checkbox', 'String', 'log');

x.attachPlotLogYUIControl(checkLogY)

checkAutoX = uicontrol('Style', 'checkbox', 'String', 'auto X', ...
    'Units', 'normalized', 'Position', [0.2 0.7 0.3 0.2]);

x.attachAutomaticXAxisControl(checkAutoX)
