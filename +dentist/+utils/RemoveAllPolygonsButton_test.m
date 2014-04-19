dentist.tests.cleanupForTests;

figure(1); 
buttonH = uicontrol('Style','pushbutton', 'String', 'removeAll', 'Enable', 'off');

mockPolygonStack = dentist.tests.MockPolygonStack();
x = dentist.utils.RemoveAllPolygonsButton(mockPolygonStack, buttonH);

assert(strcmp(get(buttonH, 'Enable'), 'off'))
assert(isempty(get(buttonH, 'Callback')))
x.enable()
assert(strcmp(get(buttonH, 'Enable'), 'on'))
assert(~isempty(get(buttonH, 'Callback')))

x.disable()
assert(strcmp(get(buttonH, 'Enable'), 'off'))
assert(isempty(get(buttonH, 'Callback')))

x.enable()

%%
