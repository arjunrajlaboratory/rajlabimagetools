improc2.tests.cleanupForTests;

annotStruct = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'hela', 'crl'}), ...
    'numNuclei', improc2.TypeCheckedNumeric(1), ...
    'notes', improc2.TypeCheckedString(''));

annotsHandle = improc2.tests.MockAnnotationsHandle(annotStruct);
annotsHandle.setValue('notes', 'some Note')

figH = figure(1);
ui = uicontrol('Style', 'edit', 'String', '', 'Units', 'normalized', ...
    'Position', [0.1 0.1 0.4, 0.3]);

x = improc2.InteractiveString('notes', annotsHandle, ui);
assert(strcmp(get(ui, 'String'), 'some Note'))


annotsHandle.setValue('notes', 'another Note')
x.update();
assert(strcmp(get(ui, 'String'), 'another Note'))

fprintf('Try writing in edit box and checking annotsHandle.getValue(''notes'')\n')
