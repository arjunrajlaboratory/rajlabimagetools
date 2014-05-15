function [rnaChannels, rnaProcessorClassName] = findRNAChannels(objectHandle)
    
    rnaProcessorClassName = 'improc2.nodeProcs.aTrousRegionalMaxProcessedData';
    rnaChannels = improc2.utils.findChannelsWithProcessorsOfRequiredType(...
        objectHandle, rnaProcessorClassName);
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

