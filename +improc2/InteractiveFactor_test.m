improc2.tests.cleanupForTests;

annotStruct = struct('isGood', improc2.TypeCheckedLogical(true), ...
    'cellType', improc2.TypeCheckedFactor({'hela', 'crl', 'a549'}), ...
    'numNuclei', improc2.TypeCheckedNumeric(1), ...
    'notes', improc2.TypeCheckedString(''));

annotsHandle = improc2.tests.MockAnnotationsHandle(annotStruct);


figH = figure(1);
ui = uicontrol('Style', 'popupmenu', 'String', 'empty', 'Units', 'normalized',...
    'Position', [0.1 0.1 0.6, 0.3]);

x = improc2.InteractiveFactor('cellType', annotsHandle, ui);


assert(strcmp(annotsHandle.getValue('cellType'), 'hela'));

choices = annotsHandle.getChoices('cellType');

assert(isequal(get(ui, 'String'), choices(:)))
assert(get(ui, 'Value') == find(strcmp('hela', choices(:))))

annotsHandle.setValue('cellType', 'a549')
x.update();
assert(get(ui, 'Value') == find(strcmp('a549', choices(:))))

fprintf('Try selecting from popupmenu and checking annotsHandle.getValue(''cellType'')\n')
