improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfUnProcessedDAGObjects();
exonChannelName = 'alexa';
intronChannelName = 'tmr';
improc2.txnSites.addTxnSiteData(exonChannelName, intronChannelName, collection);

tools = improc2.launchImageObjectTools(collection);
assert(tools.objectHandle.hasData('alexatmr:TxnSites'))
tools.objectHandle.view()