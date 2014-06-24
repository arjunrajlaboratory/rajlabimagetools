improc2.tests.cleanupForTests;

collection = improc2.tests.data.collectionOfProcessedDAGObjects();

annotsToAdd = struct();
annotsToAdd.morphology = {'smooth', 'rough'};
annotsToAdd.notes = '';
annotsToAdd.numNeighbors = 0;
improc2.addAnnotationItemsToAllObjects(annotsToAdd, collection);

x = improc2.launchThresholdGUI(collection);

%% some manual tests and bugs:

% Bug 1

% At some point the following sequence used to cause a bug:
% launch test
% open "slice excluder"
% close "slice excluder" window
% adjust a threshold/navigate object/change channel --> things are fine.
% open "slice inspector" (unrelated to slice excluder)
% adjust a threshold/navigate object/change channel --> error
% cannot find slice Excluder!
%
% the bug occurred because the sliceExcluder plugin
% judged whether it was active or not by whether or not
% the figH it had stored was deleted or not.
% turns out that matlab reuses figure Handles: 
% so if figH was originally the handle to fig. 2, it
% remains so even if fig. 2 is deleted and relaunched.
% in this case, when slice inspector was launched
% it was launched to the same figure number that was still referenced
% by the figH stored in sliceExcluderPlugin, so the excluder
% plugin thought that the sliceExcluder was active again.
% then it failed on attempts to draw.

% the fix is to have the plugins judge whether they 
% are active by looking at whether the objects they create
% such as sliceExcluder within the sliceExcluderPlugin or
% sliceBrowser within the sliceInspector Plugin are deleted
% or not, rather than by looking at whether the figure is
% deleted.
% of course, this must be coupled with making sure the
% figures delete these objects upon closeRequest, as they
% used to already.