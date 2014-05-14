improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfUnProcessedDAGObjects();

x = improc2.processing.DataAdder(collection);

%%
x.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'cy', 'cy:Spots')
x.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'alexa', 'alexa:Spots')
x.addDataToObject(improc2.nodeProcs.aTrousRegionalMaxProcessedData(), 'tmr', 'tmr:Spots')
x.addDataToObject(improc2.nodeProcs.TransProcessedData(), 'trans', 'transProc')
x.addDataToObject(improc2.nodeProcs.DapiProcessedData(), 'dapi', 'dapiProc')
x.repeatForAllObjectsAndQuit();
