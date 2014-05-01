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

oldCy = obj.processors.channels.cy.processor;
oldCy.excludedSlices = [1,3];
newCy = improc2.dataNodes.converters.procDataToNodeCompatibleData(oldCy);

assert(isa(oldCy, 'improc2.procs.aTrousRegionalMaxProcData'))
assert(isa(newCy, 'improc2.nodeProcs.aTrousRegionalMaxProcessedData'))

assert(isequal(oldCy.zMerge, newCy.zMerge))
assert(isequal(oldCy.imageSize, newCy.imageSize))
assert(isequal(oldCy.threshold, newCy.threshold))
assert(isequal(oldCy.excludedSlices, newCy.excludedSlices))
assert(isequal(oldCy.regionalMaxValues, newCy.regionalMaxValues))
assert(isequal(oldCy.regionalMaxIndices, newCy.regionalMaxIndices))

oldCy.excludedSlices = [];
newCy.excludedSlices = [];

assert(isequal(oldCy.regionalMaxValues, newCy.regionalMaxValues))
assert(isequal(oldCy.regionalMaxIndices, newCy.regionalMaxIndices))
