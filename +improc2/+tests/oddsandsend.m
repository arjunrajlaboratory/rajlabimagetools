%% improc2.RegionalMaxCDFPlotter
%
channelName = 'cy';
ob = objects(1);
imgStk = improc2.ImageObjectFullStkProvider(dirPath);
imgStk.loadImage(ob,channelName);
croppedImg = channelStk(ob, channelName, imgStk.img );
objmask = ob.object_mask.mask;
imgStk.delete()

x = improc2.procs.aTrousRegionalMaxProcData();
x = x.run(croppedImg, objmask);

pstrat = improc2.RegionalMaxCDFPlotter();
x.plotStrategy = pstrat;
figure(1); clf; ax = axes();
x.plotData(ax);

pstrat = improc2.RegionalMaxCDFPlotter(false,'Color','k','LineStyle','--');
x.plotStrategy = pstrat;
figure(2); clf; ax = axes();
x.plotData(ax);

figure(2);
fprintf('\n\n***** Click on a point in  FIGURE 2! *****\n\n')
ginput(1);
clickedpoint = get(gca,'CurrentPoint');
x = x.updateProcByDataPlotXYPOS(clickedpoint);
x.plotData(ax);

%% improc2.RegionalMaxDensityPlotter
%
channelName = 'cy';
ob = objects(1);
imgStk = improc2.ImageObjectFullStkProvider(dirPath);
imgStk.loadImage(ob,channelName);
croppedImg = channelStk(ob, channelName, imgStk.img );
objmask = ob.object_mask.mask;
imgStk.delete()

x = improc2.procs.aTrousRegionalMaxProcData();
x = x.run(croppedImg, objmask);

pstrat = improc2.RegionalMaxDensityPlotter('LineWidth',2,'Color','k');
x.plotStrategy = pstrat;
figure(1); clf; ax = axes();
x.plotData(ax);

fprintf('\n\n***** Click on a point in FIGURE 1! *****\n\n')
ginput(1);
clickedpoint = get(gca,'CurrentPoint');
x = x.updateProcByDataPlotXYPOS(clickedpoint);
x.plotData(ax);

%% improc2.processimageobjects
%
improc2.processimageobjects('directory',dirPath);
%%
chans = {'alexa','dapi'};
chantypes = {'improc2.fishSpotsChannel','improc2.dapiChannel'};
proctypes = {'improc2.procs.aTrousRegionalMaxProcData','improc2.procs.TransProcData'};
improc2.processimageobjects('directory',dirPath, 'channels', chans, ...
    'channelTypes', chantypes, 'imageProcessors', proctypes);
