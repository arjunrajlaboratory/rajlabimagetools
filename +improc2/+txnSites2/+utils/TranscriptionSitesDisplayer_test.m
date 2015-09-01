improc2.tests.cleanupForTests;

figH = figure();
axH = axes();
xlim([0 10])
ylim([0 10])

mockTxnSitesCollection = opm.txnsites.tests.MockTranscriptionSitesCollection();

x = opm.txnsites.utils.TranscriptionSitesDisplayer(axH, mockTxnSitesCollection);

mockTxnSitesCollection.addTranscriptionSite(3,4)
mockTxnSitesCollection.addTranscriptionSite(1,9)
mockTxnSitesCollection.addTranscriptionSite(5,5)
mockTxnSitesCollection.addTranscriptionSite(9,9)

x.draw()