improc2.tests.cleanupForTests;

items = struct();
items.isGood = improc2.TypeCheckedLogical(true);
items.cellType = improc2.TypeCheckedFactor({'crl','hela'});
items.notes = improc2.TypeCheckedString('');
items.numNuclei = improc2.TypeCheckedNumeric(2);
items.isMitotic = improc2.TypeCheckedYesNoOrNA();

mockNamedValuesAndChoices = improc2.tests.MockAnnotationsHandle(items);
x = improc2.utils.UISynchronizedNamedValuesAndChoices(mockNamedValuesAndChoices);

assert(x.getValue('isGood') == true)
assert(strcmp(x.getValue('cellType'), 'crl'))
assert(all(strcmp(x.getChoices('cellType'), {'crl', 'hela'})))

x.setValue('numNuclei', 4)
assert(x.getValue('numNuclei') == 4)
assert(mockNamedValuesAndChoices.getValue('numNuclei') == 4)

fig1 = figure(1);
uipopup = uicontrol('Style', 'popupmenu', 'String', 'empty', 'Units', 'normalized',...
    'Position', [0.1 0.1 0.3, 0.2]);
uicheck = uicontrol('Style', 'checkbox', 'String', 'isGood', 'Units', 'normalized',...
    'Position', [0.1 0.4 0.3, 0.2]);
uiNumNuclei = uicontrol('Style', 'edit', 'Units', 'normalized',...
    'Position', [0.4 0.1 0.2, 0.2]);
uiNotes = uicontrol('Style', 'edit', 'Units', 'normalized',...
    'Position', [0.4 0.6 0.2, 0.2]);
uipopupMitotic = uicontrol('Style', 'popupmenu', 'String', 'empty', 'Units', 'normalized',...
    'Position', [0.4 0.8 0.3, 0.15]);

x.attachUIControl('isGood', uicheck);
x.attachUIControl('cellType', uipopup);
x.attachUIControl('numNuclei', uiNumNuclei);
x.attachUIControl('notes', uiNotes);
x.attachUIControl('isMitotic', uipopupMitotic);

fig2 = figure(2);
uipopup2 = uicontrol('Style', 'popupmenu', 'String', 'empty', 'Units', 'normalized',...
    'Position', [0.1 0.1 0.3, 0.2]);
uicheck2 = uicontrol('Style', 'checkbox', 'String', 'isGood', 'Units', 'normalized',...
    'Position', [0.1 0.4 0.3, 0.2]);

x.attachUIControl('isGood', uicheck2);
x.attachUIControl('cellType', uipopup2);

% attaching and then deleting uihandles does not break the program

fig3 = figure(3);
uipopup3 = uicontrol('Style', 'popupmenu', 'String', 'empty', 'Units', 'normalized',...
    'Position', [0.1 0.1 0.3, 0.2]);
uicheck3 = uicontrol('Style', 'checkbox', 'String', 'isGood', 'Units', 'normalized',...
    'Position', [0.1 0.4 0.3, 0.2]);
x.attachUIControl('isGood', uicheck3);
x.attachUIControl('cellType', uipopup3);
delete(fig3)

x.setValue('isGood', true)
assert(get(uicheck, 'Value') == true)
assert(get(uicheck2, 'Value') == true)

x.setValue('isGood', false)
assert(get(uicheck, 'Value') == false)
assert(get(uicheck2, 'Value') == false)

% can attach actions to do after any setting operation:

a = dentist.tests.MockDrawCountingDisplayer(true);
b = dentist.tests.MockDrawCountingDisplayer(true);
x.addActionAfterSettingAnyValue(a, @draw)
x.addActionAfterSettingAnyValue(b, @draw)

assert(a.timesDrawn == 0)
assert(b.timesDrawn == 0)
x.setValue('cellType', 'hela')
assert(a.timesDrawn == 1)
assert(b.timesDrawn == 1)


fprintf('Try clicking any of the controls and checking the corresponding values in x.\n')
