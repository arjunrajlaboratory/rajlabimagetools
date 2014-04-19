improc2.tests.cleanupForTests;

x = improc2.TypeCheckedNumeric();
assert(x.value == 0)
assert(str2num(x.valueAsString) == x.value)
assert(strcmp(x.choices, 'any numeric'))

assert(isa(x, 'improc2.interfaces.TypeCheckedValue'))

x.value = 3.3;
assert(x.value == 3.3)
assert(str2num(x.valueAsString) == x.value)

improc2.tests.shouldThrowError(@() setfield(x, 'value', [2.4 5]), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', true), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 'abcd'), ...
    'improc2:InvalidValue')

x = improc2.TypeCheckedNumeric(15.3);
assert(x.value == 15.3)
x = improc2.TypeCheckedNumeric(-100);
assert(x.value == -100)

% NaN is admissible:

x = improc2.TypeCheckedNumeric(NaN);
assert(isnan(x.value))
