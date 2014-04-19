improc2.tests.cleanupForTests;

x = improc2.TypeCheckedFactor({'dog', 'cat', 'mouse'});
assert(length(x.choices) == 3)
assert(isequal(x.choices, {'dog', 'cat', 'mouse'}))
assert(strcmp(x.value, 'dog'))
assert(strcmp(x.value, x.valueAsString()))

assert(isa(x, 'improc2.interfaces.TypeCheckedValue'))

x.value = 'cat';
assert(strcmp(x.value, 'cat'))
assert(strcmp(x.valueAsString(), x.value))

improc2.tests.shouldThrowError(@() setfield(x, 'value', 'bird'), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', [true true]), ...
    'improc2:InvalidValue')
improc2.tests.shouldThrowError(@() setfield(x, 'value', 3), ...
    'improc2:InvalidValue')

x = x.addChoice('parrot');
assert(isequal(x.choices, {'dog', 'cat', 'mouse', 'parrot'}))
x.value = 'parrot';
assert(strcmp(x.value, 'parrot'))

improc2.tests.shouldThrowError(@() x.addChoice('dog'), 'improc2:ChoiceExists')
improc2.tests.shouldThrowError(@() x.addChoice(3), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() x.addChoice({'cow','donkey'}), 'improc2:BadArguments')

x = improc2.TypeCheckedFactor({'car', 'truck'});
assert(isequal(x.choices, {'car', 'truck'}))
x = improc2.TypeCheckedFactor({'truck'});
assert(isequal(x.choices, {'truck'}))

improc2.tests.shouldThrowError(@() improc2.TypeCheckedFactor({}), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() improc2.TypeCheckedFactor({2,3}), 'improc2:BadArguments')
improc2.tests.shouldThrowError(@() improc2.TypeCheckedFactor({'dog','cat','dog'}), ...
    'improc2:ChoiceExists')


x = improc2.TypeCheckedFactor({'car', 'truck'});
assert(strcmp(x.value, 'car'))
x = improc2.TypeCheckedFactor({'car', 'truck'}, 'car');
assert(strcmp(x.value, 'car'))
x = improc2.TypeCheckedFactor({'car', 'truck'}, 'truck');
assert(strcmp(x.value, 'truck'))
