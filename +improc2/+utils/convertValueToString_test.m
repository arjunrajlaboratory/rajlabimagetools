improc2.tests.cleanupForTests;

item = improc2.TypeCheckedFactor({'crl', 'hela'});
valAsStr = improc2.utils.convertValueToString(item.value, class(item));
assert(strcmp(valAsStr, 'crl'))

item = improc2.TypeCheckedLogical(false);
valAsStr = improc2.utils.convertValueToString(item.value, class(item));
assert(strcmp(valAsStr, 'false'))

item = improc2.TypeCheckedNumeric(5);
valAsStr = improc2.utils.convertValueToString(item.value, class(item));
assert(strcmp(valAsStr, '5'))

item = improc2.TypeCheckedString('anything');
valAsStr = improc2.utils.convertValueToString(item.value, class(item));
assert(strcmp(valAsStr, 'anything'))

item = improc2.TypeCheckedYesNoOrNA('NA');
valAsStr = improc2.utils.convertValueToString(item.value, class(item));
assert(strcmp(valAsStr, 'NA'))

item = struct('value', 2);
improc2.tests.shouldThrowError( ...
    @() improc2.utils.convertValueToString(item.value, class(item)));
