dentist.tests.cleanupForTests;

integerIterator = dentist.tests.IntegerIterator();
a = dentist.tests.MockSequenceRevealingDisplayer(integerIterator);
b = dentist.tests.MockSequenceRevealingDisplayer(integerIterator);

x = dentist.utils.DisplayerSequence(a,b);

assert(isempty(a.timeOfDraw) && isempty(a.timeOfDeactivate))
assert(isempty(b.timeOfDraw) && isempty(b.timeOfDeactivate))

x.draw();

assert(a.timeOfDraw == 0)
assert(b.timeOfDraw == 1)
assert(isempty(a.timeOfDeactivate))
assert(isempty(b.timeOfDeactivate))

x.draw();
assert(a.timeOfDraw == 2)
assert(b.timeOfDraw == 3)
assert(isempty(a.timeOfDeactivate))
assert(isempty(b.timeOfDeactivate))

x.deactivate()
assert(a.timeOfDeactivate == 4)
assert(b.timeOfDeactivate == 5)
