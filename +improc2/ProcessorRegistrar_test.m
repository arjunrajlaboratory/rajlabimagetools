improc2.tests.cleanupForTests;
[objH, dirPath, sliceWithSpots, imagenumber] = improc2.tests.dataForTests(); cd(dirPath) % loads an image object and a dirPath
newStyleObj = improc2.ImageObject(objH.getMask(), imagenumber, dirPath);

objHolder = improc2.utils.ObjectHolder();
objHolder.obj = newStyleObj;

x = improc2.ProcessorRegistrar(objHolder);

assert(all(ismember(x.channelNames, {'cy', 'alexa', 'tmr', 'dapi', 'trans'})))

assert(~x.hasProcessorData('cy'))
assert(~x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'cy');
assert(x.hasProcessorData('cy'))
assert(x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
assert(~x.hasProcessorData('cy', 'improc2.procs.DapiProcData'))

x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'tmr');
x.registerNewProcessor(improc2.procs.aTrousRegionalMaxProcData(), 'alexa');
x.registerNewProcessor(improc2.procs.DapiProcData(), 'dapi');
x.registerNewProcessor(improc2.procs.TransProcData(), 'trans');
assert(x.hasProcessorData('dapi', 'improc2.procs.DapiProcData'))

% add multichannel and single-channel post-processors

x.registerNewProcessor(improc2.tests.MinimalPostProcessor, 'cy');
x.registerNewProcessor(improc2.tests.MinimalPostPostProcessor, 'cy');
assert(x.hasProcessorData('cy', 'improc2.procs.aTrousRegionalMaxProcData'))
assert(x.hasProcessorData('cy', 'improc2.tests.MinimalPostProcessor'))
assert(x.hasProcessorData('cy', 'improc2.tests.MinimalPostPostProcessor'))

x.registerNewProcessor(improc2.TwoChannelSpotSumProc, {'cy','tmr'});
x.registerNewProcessor(improc2.TwoChannelSpotSumProc, {'alexa','cy'});
assert(x.hasProcessorData({'cy','tmr'}, 'improc2.TwoChannelSpotSumProc'))
assert(x.hasProcessorData({'alexa','cy'}, 'improc2.TwoChannelSpotSumProc'))
assert(~x.hasProcessorData({'alexa','tmr'}, 'improc2.TwoChannelSpotSumProc'))
