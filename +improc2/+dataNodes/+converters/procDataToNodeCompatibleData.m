function newData = procDataToNodeCompatibleData(pData)
    
    switch class(pData)
        case 'improc2.procs.aTrousRegionalMaxProcData'
            newData = convertaTrousData(pData);
        case 'improc2.procs.DapiProcData'
            newData = convertDapiProcData(pData);
        case 'improc2.procs.TransProcData'
            newData = convertTransProcData(pData);
        otherwise
            error('improc2:NoLegacySupport', 'Cannot convert processor of type %s', ...
                class(pData));
    end 
end

function newData = convertaTrousData(pData)
    filterParams = pData.filterParams;
    newData = improc2.nodeProcs.aTrousRegionalMaxProcessedData(filterParams);
    if pData.isProcessed
        newData.zMerge = pData.zMerge;
        newData.threshold = pData.threshold;
        newData.imageSize = pData.imageSize;
        
        excludedSlices = pData.excludedSlices;
        pData.excludedSlices = [];
        newData.regionalMaxValues = pData.regionalMaxValues;
        newData.regionalMaxIndices = pData.regionalMaxIndices;
        newData.excludedSlices = excludedSlices;
        
        newData.needsUpdate = false;
    end 
end


function newData = convertTransProcData(pData)
    newData = improc2.nodeProcs.TransProcessedData();
    if pData.isProcessed
        newData.middlePlane = pData.middlePlane;
        newData.needsUpdate = false;
    end
end

function newData = convertDapiProcData(pData)
    newData = improc2.nodeProcs.DapiProcessedData();
    if pData.isProcessed
        newData.mask = pData.mask;
        newData.zMerge = pData.zMerge;
        newData.needsUpdate = false;
    end
end