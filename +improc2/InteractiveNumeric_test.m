improc2.tests.cleanupForTests;

annotStruct = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'hela', 'crl'}), ...
    'numNuclei', improc2.TypeCheckedNumeric(1), ...
    'notes', improc2.TypeCheckedString(''));

annotsHandle = improc2.tests.MockAnnotationsHandle(annotStruct);

figH = figure(1);
ui = uicontrol('Style', 'edit', 'String', '', 'Units', 'normalized', ...
    'Position', [0.1 0.1 0.4, 0.3]);

x = improc2.InteractiveNumeric('numNuclei', annotsHandle, ui);

assert(str2num(get(ui, 'String')) == 1)

annotsHandle.setValue('numNuclei', 15.2)
x.update();
assert(str2num(get(ui, 'String')) == 15.2)

fprintf('Try editing the box and checking annotsHandle.getValue(''numNuclei'')\n')
