improc2.tests.cleanupForTests;

vals = struct();
vals.isGood = improc2.TypeCheckedLogical(true);
vals.cellType = improc2.TypeCheckedFactor({'crl', 'hela'});
vals.notes = improc2.TypeCheckedString('');
vals.numNuclei = improc2.TypeCheckedNumeric(2);

itemsHandle = improc2.utils.FieldsBasedItemCollectionHandle(vals);
namedValuesAndChoices = improc2.utils.NamedValuesAndChoicesFromItemCollection(itemsHandle);

UIsyncedValuesAndChoices = improc2.utils.UISynchronizedNamedValuesAndChoices(namedValuesAndChoices);

gui = improc2.launchAnnotationsGUI(UIsyncedValuesAndChoices);

gui2 = improc2.launchAnnotationsGUI(UIsyncedValuesAndChoices);
