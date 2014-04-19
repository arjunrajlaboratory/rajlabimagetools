improc2.tests.cleanupForTests;

x = improc2.TypeCheckedYesNoOrNA();
assert(length(x.choices) == 3)
assert(isequal(sort(x.choices), sort({'yes', 'no', 'NA'})))

assert(strcmp(x.value, 'NA'))
assert(strcmp(x.value, x.valueAsString()))

assert(isa(x, 'improc2.interfaces.TypeCheckedValue'))

x.value = 'yes';
assert(strcmp(x.value, 'yes'))
assert(strcmp(x.valueAsString(), x.value))

improc2.tests.shouldThrowError(@() setfield(x, 'value', 'bird'), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', {'yes', 'yes'}), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 3), ...
    'improc2:InvalidValue')

x = improc2.TypeCheckedYesNoOrNA('yes');
assert(strcmp(x.value, 'yes'))
x = improc2.TypeCheckedYesNoOrNA('no');
assert(strcmp(x.value, 'no'))
x = improc2.TypeCheckedYesNoOrNA('NA');
assert(strcmp(x.value, 'NA'))