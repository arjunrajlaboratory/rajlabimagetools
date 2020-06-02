function addBlobIntensityNode(varargin)
    
     ip = inputParser;
     ip.addOptional('dirPathOrAnArrayCollection', pwd);
     ip.addParameter('channelsToProcess', {});
     ip.addParameter('nodeLabel', []);
     ip.addParameter('blobNode', []);
     ip.parse(varargin{:});

    dirPathOrAnArrayCollection = ip.Results.dirPathOrAnArrayCollection;
    
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    
    
    
%     percentMax = ip.Results.percentMax;

    parentNodeLabels = {};
    if ~isempty(ip.Results.channelsToProcess)
        channelsToProcess = cellstr(ip.Results.channelsToProcess);
    else
        channelsToProcess = improc2.thresholdGUI.findRNAChannels(objectHandle);
    end
    
    parentNodeLabels = ip.Results.blobNode;
    for i = 1:length(channelsToProcess)
        parentNodeLabels = {parentNodeLabels, strcat(channelsToProcess{i})};
    end
    
    label = ip.Results.nodeLabel;
    if isempty(label)
        label = strcat(strcat(channelsToProcess{:}), ':BlobIntensity');
    end

    
    n_channels = length(channelsToProcess);
    if n_channels == 1
        dataAdder.addDataToObject(improc2.blobAnalyzer.blobIntensityOneChannel('nodeLabel',label, 'channelsToProcess', channelsToProcess), parentNodeLabels, label)
    elseif n_channels == 2
        dataAdder.addDataToObject(improc2.blobAnalyzer.blobIntensityTwoChannel('nodeLabel',label, 'channelsToProcess', channelsToProcess), parentNodeLabels, label)
    elseif n_channels == 3
        dataAdder.addDataToObject(improc2.blobAnalyzer.blobIntensityThreeChannel('nodeLabel',label, 'channelsToProcess', channelsToProcess), parentNodeLabels, label)
    elseif n_channels == 4
        dataAdder.addDataToObject(improc2.blobAnalyzer.blobIntensityFourChannel('nodeLabel',label, 'channelsToProcess', channelsToProcess), parentNodeLabels, label)
    elseif n_channels == 5
        dataAdder.addDataToObject(improc2.blobAnalyzer.blobIntensityFiveChannel('nodeLabel',label, 'channelsToProcess', channelsToProcess), parentNodeLabels, label)
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    
    
%     assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
%         'At least one of the channels requested to process does not exist')
%     tools = improc2.launchImageObjectTools;
    fprintf('** Adding unprocessed data templates ...')

%     dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end


