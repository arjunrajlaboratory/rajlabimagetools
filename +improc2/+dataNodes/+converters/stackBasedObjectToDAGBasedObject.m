function newObj = stackBasedObjectToDAGBasedObject(obj)
    
    imageFileMask = obj.object_mask.imfilemask;
    dirPath = obj.dirPath;
    channelInfo = struct();
    channelInfo.channelNames = obj.processors.channelFields;
    channelInfo.fileNames = cellfun(...
        @(channelName) obj.processors.channels.(channelName).filename, ...
        channelInfo.channelNames, 'UniformOutput', false);
    
    baseGraph = improc2.dataNodes.buildMinimalImageObjectGraph(...
        imageFileMask, dirPath, channelInfo);
    
    newObj = improc2.dataNodes.GraphBasedImageObject();
    newObj.graph = baseGraph;
    newObj.metadata = obj.metadata;
    newObj.annotations = obj.annotations;
    
    for i = 1:length(channelInfo.channelNames)
        channelName = channelInfo.channelNames{i};
        newNodeProcessedData = ...
            improc2.dataNodes.converters.procDataToNodeCompatibleData(...
            obj.processors.channels.(channelName).processor);
        procNode = improc2.dataNodes.Node();
        procNode.label = [channelName, ':proc'];
        procNode.data = newNodeProcessedData;
        procNode.dependencyNodeLabels = {channelName};
        newObj.graph = addNode(newObj.graph, procNode);
    end
end
