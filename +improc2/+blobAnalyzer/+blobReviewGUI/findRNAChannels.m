function [rnaChannels, rnaProcessorClassName] = findRNAChannels(objectHandle)

%% Original Code commented here in case tests are needed
% rnaProcessorClassName = 'improc2.nodeProcs.aTrousRegionalMaxProcessedData';
% rnaChannels = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
%     objectHandle, rnaProcessorClassName);

%% New code RG08082016 
% rnaProcessorClassName outputs as a key-value pair "container.Map" class
rnaProcessorClassName1 = {'improc2.nodeProcs.aTrousRegionalMaxProcessedData'};
rnaChannels1 = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
    objectHandle, rnaProcessorClassName1{1});
rnaProcessorClassName1 = repmat(rnaProcessorClassName1, [1, numel(rnaChannels1)]);

rnaProcessorClassName2 = {'improc2.nodeProcs.SparseTissueRegionalMaxProcessedData'};
rnaChannels2 = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
    objectHandle, rnaProcessorClassName2{1});
rnaProcessorClassName2 = repmat(rnaProcessorClassName2, [1, numel(rnaChannels2)]);

rnaChannels = [rnaChannels2, rnaChannels1];

rnaProcessorClassName = containers.Map(rnaChannels, [rnaProcessorClassName2 rnaProcessorClassName1]);

if isempty(rnaChannels)
    rnaProcessorClassName = 'improc2.procs.RegionalMaxProcData';
    rnaChannels = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
        objectHandle, rnaProcessorClassName);
end
if isempty(rnaChannels)
    rnaProcessorClassName = 'imageProcessors.aTrousRegionalMaxProc';
    rnaChannels = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
        objectHandle, rnaProcessorClassName);
end
assert(~isempty(rnaChannels), ...
    'The image objects do not contain processors of required type for ThresholdGUI.');
end

