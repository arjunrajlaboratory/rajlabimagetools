improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); 
newStyleObj = improc2.ImageObject(objH.getMask(), imagenumber, dirPath);

objHolder = improc2.utils.ObjectHolder();
objHolder.obj = newStyleObj;

processorRegistrar = improc2.ProcessorRegistrar(objHolder);

x = improc2.ImageObjectHandle(objHolder);

expectedChannelNames = {'alexa', 'cy', 'dapi', 'tmr', 'trans'};
assert(all(ismember(expectedChannelNames, x.channelNames)))
assert(length(x.channelNames) == length(expectedChannelNames))

x.setMetaData(struct('test1', 0, 'test2', 2))
mockMetaData = x.getMetaData();
assert(mockMetaData.test1 == 0)
assert(mockMetaData.test2 == 2)

assert(~x.hasProcessorData('cy'))
assert(~x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
processorRegistrar.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'cy');
assert(x.hasProcessorData('cy'))
assert(x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
assert(~x.hasProcessorData('cy', 'improc2.procs.DapiProcData'))

procData = improc2.utils.suppressNeedsUpdateWarning(...
    @() x.getProcessorData('cy'));
assert(isa(procData, 'improc2.procs.aTrousRegionalMaxProcData'))

procData = improc2.utils.suppressNeedsUpdateWarning(...
    @() x.getProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'));
assert(isa(procData, 'improc2.procs.aTrousRegionalMaxProcData'))
    

processorRegistrar.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'tmr');
processorRegistrar.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'alexa');
processorRegistrar.registerNewProcessor(improc2.procs.DapiProcData(), 'dapi');
processorRegistrar.registerNewProcessor(improc2.procs.TransProcData(), 'trans');

procData = improc2.utils.suppressNeedsUpdateWarning(@() x.getProcessorData('dapi'));
assert(isa(procData, 'improc2.procs.DapiProcData'))

getIsProcessedValue = @(proc) proc.isProcessed;
procIsProcessedUnProtected = @(varargin) getIsProcessedValue(x.getProcessorData(varargin{:}));
procIsProcessed = @(varargin) improc2.utils.suppressNeedsUpdateWarning(...
    procIsProcessedUnProtected, varargin{:});

assert(all(~ cellfun(procIsProcessed, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))

% run an individual processor
argsForRun = {x, 'cy'};
x.runProcessor(argsForRun, 'cy')
assert(procIsProcessed('cy'))

% run all processors
x.runAllProcessors();
assert(all(cellfun(procIsProcessed, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))

% add multichannel and single-channel post-processors

processorRegistrar.registerNewProcessor(improc2.tests.MinimalPostProcessor, 'cy');
processorRegistrar.registerNewProcessor(improc2.tests.MinimalPostPostProcessor, 'cy');
assert(x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
assert(x.hasProcessorData('cy', 'improc2.tests.MinimalPostProcessor'))
assert(x.hasProcessorData('cy', 'improc2.tests.MinimalPostPostProcessor'))

% get gets the first proc if given no parameters

procData = x.getProcessorData('cy');
assert(isa(procData, 'improc2.procs.aTrousRegionalMaxProcData'))
%%

processorRegistrar.registerNewProcessor(improc2.TwoChannelSpotSumProc, {'cy','tmr'});
processorRegistrar.registerNewProcessor(improc2.TwoChannelSpotSumProc, {'alexa','cy'});
%%
procData = improc2.utils.suppressNeedsUpdateWarning(@() x.getProcessorData({'cy','tmr'}));
assert(isa(procData, 'improc2.TwoChannelSpotSumProc'))
procData = improc2.utils.suppressNeedsUpdateWarning(...
    @() x.getProcessorData({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'));
assert(isa(procData, 'improc2.TwoChannelSpotSumProc'))

assert(x.hasProcessorData({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(x.hasProcessorData({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
assert(~x.hasProcessorData({'alexa','tmr'}, 'improc2.TwoChannelSpotSumProc'))
%%

% update will make sure everything is run.

assert(~ procIsProcessed('cy', 'improc2.tests.MinimalPostProcessor'))
assert(~ procIsProcessed('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(~ procIsProcessed({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(~ procIsProcessed({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
x.updateAllProcessors();

assert(procIsProcessed('cy', 'improc2.tests.MinimalPostProcessor'))
assert(procIsProcessed('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(procIsProcessed({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(procIsProcessed({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
% needs-update awareness.

getNeedsUpdateValue = @(proc) proc.needsUpdate;
procNeedsUpdateUnProtected = @(varargin) getNeedsUpdateValue(x.getProcessorData(varargin{:}));
procNeedsUpdate = @(varargin) improc2.utils.suppressNeedsUpdateWarning(...
    procNeedsUpdateUnProtected, varargin{:});

assert(all(~ cellfun(procNeedsUpdate, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostProcessor'))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(~ procNeedsUpdate({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(~ procNeedsUpdate({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
spotProcTmr = x.getProcessorData('tmr');
spotProcTmr.threshold = 0.8 * spotProcTmr.threshold;
x.setProcessorData(spotProcTmr, 'tmr');
%%
assert(all(~ cellfun(procNeedsUpdate, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostProcessor'))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(procNeedsUpdate({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(~ procNeedsUpdate({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
x.updateAllProcessors();

assert(all(~ cellfun(procNeedsUpdate, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostProcessor'))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(~ procNeedsUpdate({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(~ procNeedsUpdate({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
spotProcCy = x.getProcessorData('cy');
spotProcCy.threshold = 0.8 * spotProcCy.threshold;
x.setProcessorData(spotProcCy, 'cy');

assert(all(~ cellfun(procNeedsUpdate, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))
assert(procNeedsUpdate('cy', 'improc2.tests.MinimalPostProcessor'))
assert(procNeedsUpdate('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(procNeedsUpdate({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(procNeedsUpdate({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
x.updateAllProcessors();

assert(all(~ cellfun(procNeedsUpdate, {'cy', 'tmr', 'dapi', 'trans', 'alexa'})))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostProcessor'))
assert(~ procNeedsUpdate('cy', 'improc2.tests.MinimalPostPostProcessor'))
assert(~ procNeedsUpdate({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(~ procNeedsUpdate({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
%%
% test of multichannelprocessor set:

procData = x.getProcessorData({'cy', 'tmr'});
assert(~ procData.reviewed)
procData.reviewed = true;
x.setProcessorData(procData, {'cy', 'tmr'})

procData = x.getProcessorData({'cy', 'tmr'});
assert(procData.reviewed)
procData.reviewed = false;
x.setProcessorData(procData, {'cy', 'tmr'}, 'improc2.TwoChannelSpotSumProc')

procData = x.getProcessorData({'cy', 'tmr'});
assert(~ procData.reviewed)

