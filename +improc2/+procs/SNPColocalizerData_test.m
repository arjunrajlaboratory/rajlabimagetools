improc2.tests.cleanupForTests;

guideSpotXYZPositions = ...
    [ 10, 10, 3; ...
    10, 40, 1; ...
    40, 40, 5; ...
    40, 10, 2];

AspotXYZPositions = guideSpotXYZPositions(1:2, :);
BspotXYZPositions = guideSpotXYZPositions(2:3, :);

spotAmplitude = 1;
spotSigma = 1;

castIntoGaussSpotVector = @(xyz) improc2.utils.makeGaussianSpotVector(...
    xyz(:,1), xyz(:,2), spotSigma, spotAmplitude, xyz(:,3));

guideSpots = castIntoGaussSpotVector(guideSpotXYZPositions);
ASpots = castIntoGaussSpotVector(AspotXYZPositions);
BSpots = castIntoGaussSpotVector(BspotXYZPositions);

guideProcData = improc2.tests.MockFittedSpotsProcessorData(guideSpots);
AProcData = improc2.tests.MockFittedSpotsProcessorData(ASpots);
BProcData = improc2.tests.MockFittedSpotsProcessorData(BSpots);


snpMap = [];
x = improc2.procs.SNPColocalizerData(snpMap);
xProcessed = run(x, guideProcData, AProcData, BProcData);

