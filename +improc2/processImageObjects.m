function processImageObjects(dirPathOrAnArrayCollection, channelsToProcess)
    
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    
    if nargin < 2
        channelsToProcess = dataAdder.channelNames;
    end
    
    assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
        'At least one of the channels requested to process does not exist')
    
    fprintf('** Adding unprocessed data templates ...')
    for i = 1:length(channelsToProcess)
        channelName = channelsToProcess{i};
        [processorData, nodeLabel] = chooseProcessorDataForChannel(channelName);
        dataAdder.addDataToObject(processorData, channelName, nodeLabel)
        if isa(processorData, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData')
            qcData = improc2.nodeProcs.ThresholdQCData();
            qcLabel = [channelName, ':threshQC'];
            dataAdder.addDataToObject(qcData, channelName, qcLabel)
        end
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end

function [processorData, label] = chooseProcessorDataForChannel(channelName)
    switch channelName
        case 'trans'
            processorData = improc2.nodeProcs.TransProcessedData();
            label = 'transProc';
        case 'dapi'
            processorData = improc2.nodeProcs.DapiProcessedData();
            label = 'dapiProc';
        otherwise
            processorData = improc2.nodeProcs.aTrousRegionalMaxProcessedData();
            label = [channelName, ':Spots'];
    end
end