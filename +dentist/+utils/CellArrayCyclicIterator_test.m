dentist.tests.cleanupForTests;

x = dentist.utils.CellArrayCyclicIterator({'a','b',3});
assert(strcmp(x.next,'a'))
assert(strcmp(x.next,'b'))
assert(x.next == 3)
assert(strcmp(x.next,'a'))
assert(strcmp(x.next,'b'))
assert(x.next == 3)
assert(strcmp(x.next,'a'))
assert(strcmp(x.next,'b'))
x.reset();
assert(strcmp(x.next,'a'))

delete(x);
