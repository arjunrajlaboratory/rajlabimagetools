improc2.tests.cleanupForTests;

x = improc2.utils.ObjectHolder;

y = x;

x.obj = 3;
assert(x.obj == 3)
assert(y.obj == 3)

x.obj = struct();
x.obj.someField = 'anythingYouWant';

assert(strcmp(y.obj.someField, 'anythingYouWant'))
