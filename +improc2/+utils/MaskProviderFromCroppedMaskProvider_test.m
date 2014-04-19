improc2.tests.cleanupForTests;

mockCroppedMaskProvider = struct();
mockCroppedMaskProvider.getCroppedMask = @() eye(2,2);

x = improc2.utils.MaskProviderFromCroppedMaskProvider(mockCroppedMaskProvider);

assert(isequal(x.getMask(), eye(2,2)))
