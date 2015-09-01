improc2.tests.cleanupForTests;

figH = figure(1);
axH = axes('Parent', figH);
h = plot(rand(10,1), rand(10,1), 'ko');
set(h,'HitTest','off')
set(axH, 'Xlim',[0 1], 'Ylim', [0 1])

mockTxnSitesCollection = ...
    opm.txnsites.tests.MockTranscriptionSitesCollection('verbose');

x = opm.txnsites.utils.TranscriptionSiteAddingInterpreter(mockTxnSitesCollection);

x.wireToFigureAndAxes(figH, axH);