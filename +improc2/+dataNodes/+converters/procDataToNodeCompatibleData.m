function newData = procDataToNodeCompatibleData(pData)
    
    switch class(pData)
        case 'improc2.procs.aTrousRegionalMaxProcData'
            newData = convertaTrousData(pData);
        case 'improc2.procs.RegionalMaxProcData'
            newData = convertRegionalMaxData(pData);
        case 'improc2.procs.DapiProcData'
            newData = convertDapiProcData(pData);
        case 'improc2.procs.TransProcData'
            newData = convertTransProcData(pData);
    end 
end

function newData = convertaTrousData(pData)
    
end

function newData = convertRegionalMaxData(pData)
    
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