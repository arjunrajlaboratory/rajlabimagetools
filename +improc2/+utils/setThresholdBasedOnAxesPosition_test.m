improc2.tests.cleanupForTests;

mockProcessor = struct('threshold', 0.5);
mockProcessorDataHolder = improc2.tests.MockProcessorDataHolder(mockProcessor);

mockAxes = improc2.tests.MockCurrentPointAndXLimHaving();
mockAxes.set('CurrentPoint', 0.6)
xlimMin = 0; xlimMax = 1;
mockAxes.set('XLim', [xlimMin, xlimMax])

improc2.utils.setThresholdBasedOnAxesPosition(mockAxes, mockProcessorDataHolder);
assert(mockProcessorDataHolder.processorData.threshold == 0.6)

mockAxes.set('CurrentPoint', 1.4)
improc2.utils.setThresholdBasedOnAxesPosition(mockAxes, mockProcessorDataHolder);
assert(mockProcessorDataHolder.processorData.threshold == xlimMax)

mockAxes.set('CurrentPoint', -0.7)
improc2.utils.setThresholdBasedOnAxesPosition(mockAxes, mockProcessorDataHolder);
assert(mockProcessorDataHolder.processorData.threshold == xlimMin)
