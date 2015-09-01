function addTxnSiteData(exonChannelName, intronChannelName, dirPathOrAnArrayCollection)
%Builds the data nodes for trasncription sites. If there is an intorn
%channel passed, it will build a data node for intron and exons. Otherwise
%it builds an exon only data node.

IntronFlag = true;
ExonFlag = true;
if (strcmp(exonChannelName, 'none'))
    ExonFlag = false;
end
if (strcmp(intronChannelName, 'none'))
    IntronFlag = false;
end

if nargin < 3
        dirPathOrAnArrayCollection = pwd;
end
    
dataAdder = improc2.processing.DataAdder(dirPathOrAnArrayCollection);

fprintf('** Adding data templates ...')

if (IntronFlag && ExonFlag)
    parentNodeLabels = {exonChannelName, intronChannelName};
    label = [exonChannelName, intronChannelName, ':TxnSites'];
    dataAdder.addDataToObject(improc2.txnSites2.ManualExonIntronTxnSites(), parentNodeLabels, label)
    dataAdder.repeatForAllObjectsAndQuit();
else
    if(ExonFlag)
        parentNodeLabels = {exonChannelName};
        label = [exonChannelName, ':TxnSites'];
        dataAdder.addDataToObject(improc2.txnSites2.ManualExonOnlyTxnSites(), parentNodeLabels, label)
        dataAdder.repeatForAllObjectsAndQuit();
    end
end

