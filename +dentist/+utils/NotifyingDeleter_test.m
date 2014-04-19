dentist.tests.cleanupForTests;

xandy = [1 1; 15 15; 60 40; 32.5 22.5];

deletionHandler = dentist.tests.MockDeletionSettableByXYFilter(...
    xandy(:,1), xandy(:,2));

a = dentist.tests.MockDrawCountingDisplayer();
b = dentist.tests.MockDrawCountingDisplayer();

x = dentist.utils.NotifyingDeleter(deletionHandler);
x.addActionAfterDeletion(a, @draw)
x.addActionAfterDeletion(b, @draw)

assert(all(deletionHandler.deleted == [ false false false false]'))
assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

f = @(x,y) x >10 & x < 40;

x.setDeletionsToMatchXYFilter(f)
assert(all(deletionHandler.deleted == [ false true false true]'))
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)
