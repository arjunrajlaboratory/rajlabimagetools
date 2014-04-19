improc2.tests.cleanupForTests;

x = improc2.TypeCheckedLogical();
assert(x.value == true)
assert(strcmp(x.valueAsString, 'true'))

assert(all(x.choices == [true, false]))

assert(isa(x, 'improc2.interfaces.TypeCheckedValue'))

x.value = false;
assert(x.value == false)
assert(strcmp(x.valueAsString, 'false'))

improc2.tests.shouldThrowError(@() setfield(x, 'value', [true true]), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 3), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 'abcd'), ...
    'improc2:InvalidValue')

x = improc2.TypeCheckedLogical(false);
assert(x.value == false)
x = improc2.TypeCheckedLogical(true);
assert(x.value == true)
