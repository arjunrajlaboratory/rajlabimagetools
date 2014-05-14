improc2.tests.cleanupForTests;

stackBasedCollection = improc2.tests.data.collectionOfProcessedObjects();

array1 = stackBasedCollection.getObjectsArray(1);

obj = array1(1);
obj.processors.channels.alexa.processor.hasClearThreshold = 'yes';
assert(isa(obj, 'improc2.ImageObject'))

newObj = improc2.dataNodes.converters.stackBasedObjectToDAGBasedObject(obj);
assert(isa(newObj, 'improc2.dataNodes.GraphBasedImageObject'))

assert(isequal(newObj.annotations, obj.annotations))
assert(isequal(newObj.metadata, obj.metadata))

for channelName = obj.processors.channelFields
    channelName = channelName{1}; 
    channelNode = getNodeByLabel(newObj.graph, channelName);
    assert(isequal(channelNode.data.dirPath, obj.dirPath))
    assert(isequal(channelNode.data.fileName, ...
        obj.processors.channels.(channelName).filename))
    assert(isequal(channelNode.data.channelName, channelName))
    
    channelProcLabel = [channelName, ':proc'];
    procNode = getNodeByLabel(newObj.graph, channelProcLabel);
    assert(isa(procNode.data, 'improc2.interfaces.ProcessedData'))
    assert(~ procNode.data.needsUpdate)
    
    if isa(procNode.data, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData')
        qcProcLabel = [channelName, ':threshQC'];
        qcNode = getNodeByLabel(newObj.graph, qcProcLabel);
        assert(isa(qcNode.data, 'improc2.nodeProcs.ThresholdQCData'))
        assert(qcNode.data.needsUpdate)
        assert(isequal(...
            qcNode.data.hasClearThreshold, ...
            obj.processors.channels.(channelName).processor.hasClearThreshold))
    end
end
