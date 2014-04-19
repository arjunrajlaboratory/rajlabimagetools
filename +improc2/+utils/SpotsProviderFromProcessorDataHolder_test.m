improc2.tests.cleanupForTests;

I = [1, 2];
J = [10, 20];
K = [100, 200];

mockSpotsAndNumsProvider = improc2.tests.MockSpotCoordinatesProvider(I, J, K);

mockProcessorDataHolder = struct('processorData', mockSpotsAndNumsProvider);

x = improc2.utils.SpotsProviderFromProcessorDataHolder(mockProcessorDataHolder);

[i, j, k] = x.getSpotCoordinates();

assert(isequal(i, I))
assert(isequal(j, J))
assert(isequal(k, K))

assert(x.getNumSpots() == 2)
