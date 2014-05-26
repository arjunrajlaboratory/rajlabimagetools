improc2.tests.cleanupForTests;

item = improc2.TypeCheckedFactor({'crl', 'hela'});
choicesAsStr = improc2.utils.convertChoicesToString(item.choices, class(item));
assert(strcmp(choicesAsStr, improc2.utils.stringJoin(item.choices, ', ')))

item = improc2.TypeCheckedLogical(false);
choicesAsStr = improc2.utils.convertChoicesToString(item.choices, class(item));
assert(strcmp(choicesAsStr, 'logical true or false'))

item = improc2.TypeCheckedNumeric(5);
choicesAsStr = improc2.utils.convertChoicesToString(item.choices, class(item));
assert(strcmp(choicesAsStr, item.choices))

item = improc2.TypeCheckedString('anything');
choicesAsStr = improc2.utils.convertChoicesToString(item.choices, class(item));
assert(strcmp(choicesAsStr, item.choices))

item = improc2.TypeCheckedYesNoOrNA('NA');
choicesAsStr = improc2.utils.convertChoicesToString(item.choices, class(item));
assert(strcmp(choicesAsStr, improc2.utils.stringJoin(item.choices, ', ')))

item = struct('choices', 2);
improc2.tests.shouldThrowError( ...
    @() improc2.utils.convertChoicesToString(item.choices, class(item)));
