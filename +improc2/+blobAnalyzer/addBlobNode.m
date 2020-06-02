function addBlobNode(varargin)
    
     ip = inputParser;
     ip.addOptional('dirPathOrAnArrayCollection', pwd);
     ip.addParameter('channelsToProcess', {'gfp'});
%      ip.addParameter('percentMax', .5);
     ip.addParameter('nodeLabel', []);
     ip.parse(varargin{:});

    dirPathOrAnArrayCollection = ip.Results.dirPathOrAnArrayCollection;
    
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    
    channelsToProcess = cellstr(ip.Results.channelsToProcess);
    
%     percentMax = ip.Results.percentMax;
    
    
    assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
        'At least one of the channels requested to process does not exist')
%     tools = improc2.launchImageObjectTools;
    fprintf('** Adding unprocessed data templates ...')
    for i = 1:length(channelsToProcess)
        channelName = channelsToProcess{i};
        
        if isempty(ip.Results.nodeLabel)
            nodeLabel = [channelName, ':Blob'];
        else
            nodeLabel = ip.Results.nodeLabel;
        end
        
        channelName = {channelName, channelName, 'dapi'};
        
%         processorData = blobCollectionOneChannel(tools.objectHandle, 'channels', channelsToProcess, 'percentMax', percentMax, 'nodeLabel', nodeLabel);
        processorData = improc2.blobAnalyzer.blobCollectionOneChannel('channels', channelsToProcess, 'nodeLabel', nodeLabel);
        dataAdder.addDataToObject(processorData, channelName, nodeLabel)
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end


