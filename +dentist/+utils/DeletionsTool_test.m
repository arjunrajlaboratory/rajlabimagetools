dentist.tests.cleanupForTests;

a = dentist.tests.MockDrawCountingDisplayer();
b = dentist.tests.MockDrawCountingDisplayer();

indicatorFUNC = @(x,y) x > 40 & y > 50;
criteriaSource = dentist.tests.MockDeletionCriteriaProvider(indicatorFUNC);
xs = [34, 50, 14];
ys = [56, 60, 11];
deleter = dentist.tests.MockDeleter(xs, ys);

x = dentist.utils.DeletionsTool(deleter, criteriaSource);
x.addObjectToDrawWhenADeletionHappens(a);
x.addObjectToDrawWhenADeletionHappens(b);

assert(all(deleter.deleted == [false false false]))
assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)

x.applyDeletion()
assert(all(deleter.deleted == [false true false]))
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)
