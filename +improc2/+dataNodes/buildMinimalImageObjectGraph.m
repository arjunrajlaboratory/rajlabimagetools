function graph = buildMinimalImageObjectGraph(...
        imageFileMask, dirPath, structOfChannelNamesAndFileNames)
    
    channelNames = structOfChannelNamesAndFileNames.channelNames;
    fileNames = structOfChannelNamesAndFileNames.fileNames;
    
    graph = improc2.dataNodes.DirectedAcyclicGraph();
    
    imObjBaseData = improc2.dataNodes.ImageObjectBaseData();
    imObjBaseData.imfilemask = imageFileMask;
    
    imObjRootNode = improc2.dataNodes.Node();
    imObjRootNode.data = imObjBaseData;
    imObjRootNode.label = 'imageObject';
    
    graph = addNode(graph, imObjRootNode);
    

    
    for i = 1:length(channelNames)
        channelData = improc2.dataNodes.ChannelStackContainer();
        channelData.channelName = channelNames{i};
        channelData.fileName = fileNames{i};
        channelData.dirPath = dirPath;
        
        channelNode = improc2.dataNodes.Node();
        channelNode.data = channelData;
        channelNode.label = channelData.channelName;
        channelNode.dependencyNodeLabels = {'imageObject'};
        
        graph = addNode(graph, channelNode);
    end
    
end

