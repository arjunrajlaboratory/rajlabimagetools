improc2.tests.cleanupForTests;

x = improc2.ProcessorDataGraph({'cy','tmr','dapi'}); 

assert(isequal(x.channelNames, {'cy','tmr','dapi'}))

%% add a cy processor

vertex.processorData = improc2.procs.aTrousRegionalMaxProcData();
vertex.vertexNumbersOfDependencies = [];
vertex.channelNamesOfRawImageDependencies = {'cy'};


assert(isempty(x.vertices))
x = addVertex(x, vertex);
assert(x.vertices{1}.number == 1)
assert(isa(x.vertices{1}.processorData, 'improc2.procs.aTrousRegionalMaxProcData'))
assert(isempty(x.vertices{1}.vertexNumbersOfDependencies))
assert(isequal(x.vertices{1}.channelNamesOfRawImageDependencies, {'cy'}))
assert(isempty(x.vertices{1}.vertexNumbersOfDependents));

%% add a cy post-processor

vertex.processorData = improc2.procs.TwoStageGaussianSpotFitProcessorData;
vertex.vertexNumbersOfDependencies = 1;
vertex.channelNamesOfRawImageDependencies = {'cy'};

assert(length(x.vertices) == 1)
x = addVertex(x, vertex);
assert(length(x.vertices) == 2)
assert(x.vertices{2}.number == 2)
assert(isa(x.vertices{2}.processorData, 'improc2.procs.TwoStageGaussianSpotFitProcessorData'))

assert(x.vertices{2}.vertexNumbersOfDependencies == 1)
assert(isequal(x.vertices{2}.channelNamesOfRawImageDependencies, {'cy'}))
assert(isempty(x.vertices{2}.vertexNumbersOfDependents));
assert(x.vertices{1}.vertexNumbersOfDependents == 2);

assert(isequal(x.vertexNumbersOfRawImageDependents.('cy'), [1 2]))


%% add a dapi processor

vertex.processorData = improc2.procs.DapiProcData;
vertex.vertexNumbersOfDependencies = [];
vertex.channelNamesOfRawImageDependencies = {'dapi'};

x = addVertex(x, vertex);
assert(length(x.vertices) == 3)
assert(isequal(x.vertexNumbersOfRawImageDependents.('cy'), [1 2]))
assert(isequal(x.vertexNumbersOfRawImageDependents.('dapi'), 3))

%% add tmr processor and post processor.

vertex.processorData = improc2.procs.aTrousRegionalMaxProcData();
vertex.vertexNumbersOfDependencies = [];
vertex.channelNamesOfRawImageDependencies = {'tmr'};

x = addVertex(x, vertex);

vertex.processorData = improc2.procs.TwoStageGaussianSpotFitProcessorData;
vertex.vertexNumbersOfDependencies = 4;
vertex.channelNamesOfRawImageDependencies = {'tmr'};

x = addVertex(x, vertex);

%% add a post processor on the tmr and cy post processors

vertex.processorData = improc2.TwoChannelSpotSumProc();
vertex.vertexNumbersOfDependencies = [2, 5];
vertex.channelNamesOfRawImageDependencies = {};

x = addVertex(x, vertex);