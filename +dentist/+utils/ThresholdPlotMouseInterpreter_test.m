dentist.tests.cleanupForTests;

vals = [1:5, 10:13];
cyTable = dentist.utils.SpotFrequencyTable(vals);
vals = [20:25, 50:60];
tmrTable = dentist.utils.SpotFrequencyTable(vals);
spotTables = dentist.utils.ChannelArray({'cy','tmr'});
spotTables = spotTables.setByChannelName(cyTable, 'cy');
spotTables = spotTables.setByChannelName(tmrTable, 'tmr');
mockFreqTablsSource = dentist.utils.FrequencyTableSource(spotTables);

figH = figure(1); axH = axes('Parent', figH);

mockThresholdsHolder = ...
    dentist.tests.MockThresholdHolder(struct('cy', 8, 'tmr', 40));


channelHolder = dentist.utils.ChannelHolder('cy');

threshPlotPlugin = dentist.utils.ThresholdPlotPlugin(axH, mockThresholdsHolder, ...
    mockFreqTablsSource, channelHolder);

threshPlotPlugin.draw();

x = dentist.utils.ThresholdPlotMouseInterpreter(threshPlotPlugin);
x.wireToFigureAndAxes(figH, axH)

title('Left click to place thresh. drag range to zoom in. Right click zoom out')
