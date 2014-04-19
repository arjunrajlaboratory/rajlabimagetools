improc2.tests.cleanupForTests;

x = improc2.TypeCheckedString();
assert(strcmp(x.value, ''))
assert(strcmp(x.valueAsString, x.value))
assert(strcmp(x.choices, 'any string'))

assert(isa(x, 'improc2.interfaces.TypeCheckedValue'))

x.value = 'anyString';
assert(strcmp(x.value, 'anyString'))
assert(strcmp(x.valueAsString, x.value))

improc2.tests.shouldThrowError(@() setfield(x, 'value', {'a', 'b'}), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 3), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', true), ...
    'improc2:InvalidValue')

x = improc2.TypeCheckedString('someOtherString');
assert(strcmp(x.value, 'someOtherString'))
x = improc2.TypeCheckedString('blahBlah');
assert(strcmp(x.value, 'blahBlah'))
