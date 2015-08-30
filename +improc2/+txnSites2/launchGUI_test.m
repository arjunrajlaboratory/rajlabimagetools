improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();
exonChannelName = 'alexa';
intronChannelName = 'tmr';

tools = improc2.launchImageObjectTools(collection);


looctools = improc2.txnSites.launchGUI(exonChannelName, intronChannelName, collection);
