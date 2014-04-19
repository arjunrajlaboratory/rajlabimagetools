improc2.tests.cleanupForTests;

annotStruct = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'hela', 'crl'}), ...
    'numNuclei', improc2.TypeCheckedNumeric(1), ...
    'notes', improc2.TypeCheckedString(''));

annotsHandle = improc2.tests.MockAnnotationsHandle(annotStruct);

figH = figure(1);
ui = uicontrol('Style', 'checkbox', 'String', 'isGood');

x = improc2.InteractiveLogical('isGood', annotsHandle, ui);

assert(get(ui, 'Max') == true)
assert(get(ui, 'Min') == false)
assert(get(ui, 'Value') == true)

annotsHandle.setValue('isGood',false)
x.update();
assert(get(ui, 'Value') == false)

fprintf('Try clicking on checkbox and running annotsHandle.getValue(''isGood'')\n')

