function processImageObjects_expansion(varargin)
    
     ip = inputParser;
     ip.addOptional('dirPathOrAnArrayCollection', pwd);
     ip.addOptional('channelsToProcess', {});
     ip.addOptional('node_name',':Spots_Expansion') 
     ip.addParameter('filterParams', struct('sigma',1,'numLevels',4));
     ip.parse(varargin{:});

    dirPathOrAnArrayCollection = ip.Results.dirPathOrAnArrayCollection;
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    channelsToProcess = cellstr(ip.Results.channelsToProcess);
    node_name = ip.Results.node_name;
    
    filterParams = ip.Results.filterParams;
    
    if isempty(channelsToProcess)
        channelsToProcess = dataAdder.channelNames;
    end
    
    
    assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
        'At least one of the channels requested to process does not exist')
    
    fprintf('** Adding unprocessed data templates ...')
    for i = 1:length(channelsToProcess)
        channelName = channelsToProcess{i};
        [processorData, nodeLabel] = chooseProcessorDataForChannel(channelName, filterParams, node_name);
        dataAdder.addDataToObject(processorData, channelName, nodeLabel)
        if strcmp(nodeLabel, [channelName, node_name]) 
%             isa(processorData, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData')
            qcData = improc2.nodeProcs.ThresholdQCData();
            qcLabel = [channelName, ':threshQC', node_name];
            dataAdder.addDataToObject(qcData, nodeLabel, qcLabel)
        end
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end

function [processorData, label] = chooseProcessorDataForChannel(channelName, filterParams, node_name)
    switch channelName
        case 'trans'
            processorData = improc2.nodeProcs.TransProcessedData();
            label = 'transProc';
        case 'dapi'
            processorData = improc2.nodeProcs.DapiProcessedData();
            label = 'dapiProc';
        otherwise
            processorData = improc2.nodeProcs.aTrousRegionalMaxProcessedData('filterParams', filterParams);
            label = [channelName, node_name];
            disp(label)
    end
end