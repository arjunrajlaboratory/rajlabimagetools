function processImageObjects(varargin)
    
     ip = inputParser;
     ip.addOptional('sparseTissue', false);
     ip.addOptional('dirPathOrAnArrayCollection', pwd);
     ip.addOptional('channelsToProcess', {});
     ip.addParameter('filterParams', struct('sigma',0.5,'numLevels',3));
     ip.parse(varargin{:});
     
     sparseTissue = ip.Results.sparseTissue;

    dirPathOrAnArrayCollection = ip.Results.dirPathOrAnArrayCollection;
    
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    
    channelsToProcess = cellstr(ip.Results.channelsToProcess);
    
    filterParams = ip.Results.filterParams;
    
    if isempty(channelsToProcess)
        channelsToProcess = dataAdder.channelNames;
    end
    
    
    assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
        'At least one of the channels requested to process does not exist')
    
    fprintf('** Adding unprocessed data templates ...')
    for i = 1:length(channelsToProcess)
        channelName = channelsToProcess{i};
        [processorData, nodeLabel] = chooseProcessorDataForChannel(channelName, filterParams, sparseTissue);
        dataAdder.addDataToObject(processorData, channelName, nodeLabel)
        if isa(processorData, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData') || isa(processorData, 'improc2.nodeProcs.SparseTissueRegionalMaxProcessedData')
            qcData = improc2.nodeProcs.ThresholdQCData();
            qcLabel = [channelName, ':threshQC'];
            dataAdder.addDataToObject(qcData, channelName, qcLabel)
        end
    end
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end

function [processorData, label] = chooseProcessorDataForChannel(channelName, filterParams, sparseTissue)
    switch channelName
        case 'alexa'
            % In case sparseTissue is set to true, assign the
            % "SparseTissueRegionalMaxProcessedData processor to the
            % "alexa" channel to reduce doubly called spots
            if sparseTissue
                processorData = improc2.nodeProcs.SparseTissueRegionalMaxProcessedData('filterParams', filterParams);
                label = 'alexaSparseProc';
            else
                processorData = improc2.nodeProcs.aTrousRegionalMaxProcessedData('filterParams', filterParams);
                label = [channelName, ':Spots'];
            end
        case 'trans'
            processorData = improc2.nodeProcs.TransProcessedData();
            label = 'transProc';
        case 'dapi'
            processorData = improc2.nodeProcs.DapiProcessedData();
            label = 'dapiProc';
        otherwise
            processorData = improc2.nodeProcs.aTrousRegionalMaxProcessedData('filterParams', filterParams);
            label = [channelName, ':Spots'];
    end
end