improc2.tests.cleanupForTests;

stackBasedCollection = improc2.tests.data.collectionOfProcessedObjects();

array1 = stackBasedCollection.getObjectsArray(1);

obj = array1(1);
assert(isa(obj, 'improc2.ImageObject'))

oldDapi = obj.processors.channels.dapi.processor;
newDapi = improc2.dataNodes.converters.procDataToNodeCompatibleData(oldDapi);

assert(isa(oldDapi, 'improc2.procs.DapiProcData'))
assert(isa(newDapi, 'improc2.nodeProcs.DapiProcessedData'))

assert(isequal(oldDapi.zMerge, newDapi.zMerge))
assert(isequal(oldDapi.mask, newDapi.mask))
assert(~newDapi.needsUpdate);
    
oldTrans = obj.processors.channels.trans.processor;
newTrans = improc2.dataNodes.converters.procDataToNodeCompatibleData(oldTrans);

assert(isa(oldTrans, 'improc2.procs.TransProcData'))
assert(isa(newTrans, 'improc2.nodeProcs.TransProcessedData'))
assert(~newTrans.needsUpdate);

assert(isequal(oldTrans.middlePlane, newTrans.middlePlane))