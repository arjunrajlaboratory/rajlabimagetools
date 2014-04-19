improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath
x = improc2.MultiChannelProcManager(imagenumber,dirPath);
x = x.registerSingleChanProcessor('cy',improc2.procs.aTrousRegionalMaxProcData);

% Tests of registration.
improc2.tests.shouldThrowError(...
    @() x.registerMultiChanProcessor({'cy','tmr'}, improc2.procs.aTrousRegionalMaxProcData));
improc2.tests.shouldThrowError(...
    @() x.registerMultiChanProcessor({'cy'}, improc2.TwoChannelSpotSumProc), ...
    'improc2:BadArguments');
improc2.tests.shouldThrowError(...
    @() x.registerMultiChanProcessor({'cy', 1}, improc2.TwoChannelSpotSumProc), ...
    'improc2:BadArguments');
improc2.tests.shouldThrowError(...
    @() x.registerMultiChanProcessor({'cy','tmr'}, improc2.TwoChannelSpotSumProc),...
    'improc2:DependencyNotFound');
x = x.registerSingleChanProcessor('tmr', improc2.procs.aTrousRegionalMaxProcData);
x = x.registerMultiChanProcessor({'cy','tmr'}, improc2.TwoChannelSpotSumProc);
x = x.registerSingleChanProcessor('alexa', improc2.procs.aTrousRegionalMaxProcData);
x = x.registerMultiChanProcessor({'alexa','cy'}, improc2.TwoChannelSpotSumProc);
assert(length(x) == 2);


% test of running.
x = x.runAllSingleChanProcsUsingImgObjHandle(objH);
x = x.runProcAtIndex(1);
x = x.runProcAtIndex(2);
assert(x.multiChanProcs(1).getNumSpots == ...
    x.channels.cy.processor.getNumSpots + x.channels.tmr.processor.getNumSpots);
assert(x.multiChanProcs(2).getNumSpots == ...
    x.channels.alexa.processor.getNumSpots + x.channels.cy.processor.getNumSpots);


% test of checking existence by class name
assert(x.hasMultiChanProcMatchingSourceAndClass({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(x.hasMultiChanProcMatchingSourceAndClass({'cy','tmr'}, 'improc2.SpotFindingInterface'))
assert(x.hasMultiChanProcMatchingSourceAndClass({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%order matters
assert(~ x.hasMultiChanProcMatchingSourceAndClass({'tmr','cy'}, 'improc2.TwoChannelSpotSumProc'))

% test of getting by class name
fetchedProc = x.getMultiChanProcBySourceByClass({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc');
assert(fetchedProc.getNumSpots() == ...
    x.channels.cy.processor.getNumSpots + x.channels.tmr.processor.getNumSpots);

fetchedProc = x.getMultiChanProcBySourceByClass({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc');
assert(fetchedProc.getNumSpots() == ...
    x.channels.alexa.processor.getNumSpots + x.channels.cy.processor.getNumSpots);
assert(isa(fetchedProc, 'improc2.TwoChannelSpotSumProc'));

x = x.registerMultiChanProcessor({'cy', 'tmr'}, improc2.TwoChannelSpotSumProc());

% can get first or last:
fetchedProc = x.getMultiChanProcBySourceByClass({'cy','tmr'}, ...
    'improc2.TwoChannelSpotSumProc', 'first');
assert(fetchedProc.isProcessed);
newProc = x.getMultiChanProcBySourceByClass({'cy','tmr'}, ...
    'improc2.TwoChannelSpotSumProc', 'last');
assert(~ newProc.isProcessed);

% test of getting by position
fetchedProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 1);
assert(fetchedProc.isProcessed);
newProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 2);
assert(~ newProc.isProcessed);

% test of running by position

extraArgs = {};
x = x.runMultiChanProcBySourceByPos(extraArgs, {'cy', 'tmr'}, 2);
newProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 2);
assert(newProc.isProcessed);

% test of setting by class name

x = x.setMultiChanProcBySourceByPos(improc2.TwoChannelSpotSumProc('setTest1'), {'cy','tmr'}, 2);
newProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 2);
assert(strcmp(newProc.description, 'setTest1'));
x = x.setMultiChanProcBySourceByClass(improc2.TwoChannelSpotSumProc('setTest2'), ...
    {'cy','tmr'}, 'improc2.TwoChannelSpotSumProc', 'last');
newProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 2);
assert(strcmp(newProc.description, 'setTest2'));
assert(~ newProc.isProcessed)

% test of running by class name
extraArgs = {};
x = x.runMultiChanProcBySourceByClass(extraArgs, ...
    {'cy','tmr'}, 'improc2.TwoChannelSpotSumProc', 'last');
newProc = x.getMultiChanProcBySourceByPos({'cy','tmr'}, 2);
assert(newProc.isProcessed)

% tests of needs update sensing
x.channels.cy.processor.threshold = 0.8 * x.channels.cy.processor.threshold;
assert(x.multiChanProcs(1).needsUpdate && x.multiChanProcs(2).needsUpdate)
x = x.runProcAtIndex(1);
x = x.runProcAtIndex(2);
assert(~x.multiChanProcs(1).needsUpdate && ~x.multiChanProcs(2).needsUpdate)
x.channels.alexa.processor.threshold = 0.8 * x.channels.alexa.processor.threshold;
assert(~x.multiChanProcs(1).needsUpdate && x.multiChanProcs(2).needsUpdate)
% tests of running All
x = x.runAllMultiChanProcs;
assert(~x.multiChanProcs(1).needsUpdate && ~x.multiChanProcs(2).needsUpdate)
% tests of updating All
x.channels.alexa.processor.threshold = 0.8 * x.channels.alexa.processor.threshold;
assert(~x.multiChanProcs(1).needsUpdate && x.multiChanProcs(2).needsUpdate)
x = x.updateAllMultiChanProcs;
assert(~x.multiChanProcs(1).needsUpdate && ~x.multiChanProcs(2).needsUpdate)
