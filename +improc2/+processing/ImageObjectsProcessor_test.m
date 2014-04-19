improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfUnProcessedObjects();

x = improc2.processing.ImageObjectsProcessor(collection);

browsingTools = improc2.launchImageObjectBrowsingTools(collection);

assert(isequal(sort(x.availableChannels), ...
    sort(browsingTools.objectHandle.channelNames)))

%% test defaults

assert(isequal(sort(x.channelsToProcess), sort(x.availableChannels)))

initialProcData = x.initialProcessorData;

for channelName = initialProcData.channelNames
    procData = initialProcData.getByChannelName(channelName);
    switch char(channelName)
        case 'dapi'
            assert(isa(procData, 'improc2.procs.DapiProcData'))
        case 'trans'
            assert(isa(procData, 'improc2.procs.TransProcData'))
        otherwise
            assert(isa(procData, 'improc2.procs.aTrousRegionalMaxProcData'))
    end
end

%% channels to process

x.setChannelsToProcess({'cy', 'dapi'})
assert(isequal(sort(x.channelsToProcess), sort({'cy', 'dapi'})))

x.setChannelsToProcess({'tmr', 'trans'})
assert(isequal(sort(x.channelsToProcess), sort({'tmr', 'trans'})))

improc2.tests.shouldThrowError(...
    @() x.setChannelsToProcess({'notAnAvailableChannel'}), ...
    'improc2:BadArguments')

%% Processor to use

x.setProcessorDataForChannel(improc2.procs.DapiProcData(), 'tmr')

assert(isa(x.initialProcessorData.getByChannelName('tmr'), ...
    'improc2.procs.DapiProcData'))

%% Run

x.setChannelsToProcess({'cy', 'dapi'})
x.run()

browsingTools.refresh();

getIsProcessedValue = @(proc) ...
    proc.isProcessed;

getProcData = @(varargin) ...
    browsingTools.objectHandle.getProcessorData(varargin{:});

getProcDataProtected = @(varargin) ...
    improc2.utils.suppressNeedsUpdateWarning(getProcData, varargin{:});

procIsProcessed = @(varargin) ...
    getIsProcessedValue(getProcDataProtected(varargin{:}));
    

assert(isa(getProcData('cy'), 'improc2.procs.aTrousRegionalMaxProcData'))
assert(procIsProcessed('cy'))
assert(isa(getProcData('dapi'), 'improc2.procs.DapiProcData'))
assert(procIsProcessed('dapi'))

assert(~ browsingTools.objectHandle.hasProcessorData('tmr'))
assert(~ browsingTools.objectHandle.hasProcessorData('alexa'))
assert(~ browsingTools.objectHandle.hasProcessorData('trans'))


%% Run fails if run  on channels that have already been processed:

x = improc2.processing.ImageObjectsProcessor(collection);
x.setChannelsToProcess({'cy'})

improc2.tests.shouldThrowError(@x.run, 'improc2:ProcExists')

%% But if we initialize with the appropriate flag it won't

optionalFlags = struct();
optionalFlags.failIfProcessorExists = false;

x = improc2.processing.ImageObjectsProcessor(collection, optionalFlags);
x.setChannelsToProcess({'cy'})

x.run()