improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfUnProcessedDAGObjects();

tools = improc2.launchImageObjectTools(collection);

channelNames = tools.objectHandle.channelNames;

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration;
    for channelName = channelNames
        assert(~ tools.objectHandle.hasData(channelName))
    end
    tools.iterator.goToNextObject();
end

%% processing just some channels

channelsToProcess = {'dapi', 'trans', 'cy'};
improc2.processImageObjects(collection, channelsToProcess)
tools.refresh();

hasProcOfClass = @(channelName, className) tools.objectHandle.hasData(channelName, className);

needsUpdate = @(varargin) getfield(tools.objectHandle.getData(varargin), 'needsUpdate');

rnaChannelSetupCorrectly = @(channelName) ...
    hasProcOfClass(channelName, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData') && ...
    hasProcOfClass(channelName, 'improc2.nodeProcs.ThresholdQCData') && ...
    hasProcOfClass([channelName, ':Spots'], 'improc2.nodeProcs.aTrousRegionalMaxProcessedData') && ...
    hasProcOfClass([channelName, ':threshQC'], 'improc2.nodeProcs.ThresholdQCData') && ...
    ~ needsUpdate([channelName, ':Spots']);

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration;
    assert(hasProcOfClass('dapi', 'improc2.nodeProcs.DapiProcessedData'))
    assert(hasProcOfClass('dapiProc', 'improc2.nodeProcs.DapiProcessedData'))
    assert(~needsUpdate('dapiProc'))
    assert(hasProcOfClass('trans', 'improc2.nodeProcs.TransProcessedData'))
    assert(hasProcOfClass('transProc', 'improc2.nodeProcs.TransProcessedData'))
    assert(~needsUpdate('transProc'))
    assert(rnaChannelSetupCorrectly('cy'))
    assert(~ tools.objectHandle.hasData('tmr'))
    assert(~ tools.objectHandle.hasData('alexa'))
    tools.iterator.goToNextObject();
end

%% processing all channels by omitting the channelsToProcess argument

improc2.processImageObjects(collection)
tools.refresh();

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration;
    assert(hasProcOfClass('dapi', 'improc2.nodeProcs.DapiProcessedData'))
    assert(hasProcOfClass('dapiProc', 'improc2.nodeProcs.DapiProcessedData'))
    assert(~needsUpdate('dapiProc'))
    assert(hasProcOfClass('trans', 'improc2.nodeProcs.TransProcessedData'))
    assert(hasProcOfClass('transProc', 'improc2.nodeProcs.TransProcessedData'))
    assert(~needsUpdate('transProc'))
    assert(rnaChannelSetupCorrectly('cy'))
    assert(rnaChannelSetupCorrectly('tmr'))
    assert(rnaChannelSetupCorrectly('alexa'))
    tools.iterator.goToNextObject();
end
