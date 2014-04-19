improc2.tests.cleanupForTests;

collection = improc2.tests.data.smallCollectionOfProcessedObjects();

tools = improc2.launchImageObjectTools(collection);

hasGaussianData = ...
    @(chanName) tools.objectHandle.hasProcessorData(chanName, ...
    'improc2.procs.TwoStageGaussianSpotFitProcessorData');

haveGaussianData = @(chanNames) cellfun(hasGaussianData, chanNames);

channelNames = tools.objectHandle.channelNames;
assert(~any(haveGaussianData(channelNames)))


assert(~tools.objectHandle.hasProcessorData('trans', 'improc2.SpotFindingInterface'))
assert(tools.objectHandle.hasProcessorData('tmr', 'improc2.SpotFindingInterface'))
assert(tools.objectHandle.hasProcessorData('alexa', 'improc2.SpotFindingInterface'))

assert(tools.objectHandle.hasProcessorData('cy', 'improc2.SpotFindingInterface'))
improc2.processing.fitGaussiansToSpots(collection, {'cy'})
tools.refresh();

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration
    assert(hasGaussianData('cy'))
    assert(~any(haveGaussianData({'trans', 'alexa', 'trans', 'dapi'})))
    tools.iterator.goToNextObject();
end

assert(~tools.objectHandle.hasProcessorData('dapi', 'improc2.SpotFindingInterface'))
improc2.tests.shouldThrowError( ...
    @() improc2.processing.fitGaussiansToSpots(collection, {'dapi'}));


improc2.processing.fitGaussiansToSpots(collection)
tools.refresh();

tools.iterator.goToFirstObject();
while tools.iterator.continueIteration
    assert(all(haveGaussianData({'cy', 'alexa', 'tmr'})))
    assert(~any(haveGaussianData({'trans', 'dapi'})))
    tools.iterator.goToNextObject();
end