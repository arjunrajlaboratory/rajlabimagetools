function addTxnSiteData(exonChannelName, intronChannelName, dirPathOrAnArrayCollection)


if nargin < 3
        dirPathOrAnArrayCollection = pwd;
end
    
dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);


% assert(all(ismember(channelsToProcess, dataAdder.channelNames)), ...
%     'At least one of the channels requested to process does not exist')

fprintf('** Adding data templates ...')
parentNodeLabels = {exonChannelName, intronChannelName};
label = [exonChannelName, intronChannelName, ':TxnSites'];
dataAdder.addDataToObject(improc2.txnSites.ManualExonIntronTxnSites(), parentNodeLabels, label)
dataAdder.repeatForAllObjectsAndQuit();