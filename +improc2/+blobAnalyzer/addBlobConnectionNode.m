function addBlobConnectionNode(parentNodeLabel1, parentNodeLabel2, varargin)
    
     ip = inputParser;
     ip.addOptional('dirPathOrAnArrayCollection', pwd);
     ip.addParameter('nodeLabel', 'blobConnections');
     ip.parse(varargin{:});
     
     nodeLabel = ip.Results.nodeLabel;
    dirPathOrAnArrayCollection = ip.Results.dirPathOrAnArrayCollection;
    
    dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);
    
        

    fprintf('** Adding unprocessed data templates ...')
    tools = improc2.launchImageObjectTools;
    dataClass = class(tools.objectHandle.getData(parentNodeLabel1));
    
    if strcmp(dataClass, 'improc2.txnSites2.ManualExonIntronTxnSites')
        processorData = improc2.blobAnalyzer.blobConnectionCollectionOneChannel(parentNodeLabel1, parentNodeLabel2, 'nodeLabel', nodeLabel);
    else
        processorData = improc2.blobAnalyzer.blobConnectionCollectionOneBlobChannelOneTxnSiteChannel(parentNodeLabel1, parentNodeLabel2, 'nodeLabel', nodeLabel);
    end
        
        
    dataAdder.addDataToObject(processorData,{parentNodeLabel1, parentNodeLabel2}, nodeLabel)
    
    dataAdder.repeatForAllObjectsAndQuit();
    
    fprintf('** Processing ...')
    improc2.processing.updateAll(dirPathOrAnArrayCollection);
end


