dentist.tests.cleanupForTests;

figure(1);
set(gcf,'Position', [966   542   339   283]);
b = struct();
b.button1 = uicontrol('Parent', gcf, 'Style', 'togglebutton', 'String', 'Button1',...
    'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.2]);
b.button2 = uicontrol('Parent', gcf, 'Style', 'togglebutton', 'String', 'Button2',...
    'Units', 'normalized', 'Position', [0.05 0.3 0.9 0.2]);
b.button3 = uicontrol('Parent', gcf, 'Style', 'togglebutton', 'String', 'Button3',...
    'Units', 'normalized', 'Position', [0.05 0.6 0.9 0.2]);

x = dentist.utils.MutuallyExclusiveToggleGroup(b);
x.initialize();

assert(get(b.button1, 'Value') == 1)
assert(get(b.button2, 'Value') == 0)
assert(get(b.button3, 'Value') == 0)
x.activateButton('button2')
assert(get(b.button1, 'Value') == 0)
assert(get(b.button2, 'Value') == 1)
assert(get(b.button3, 'Value') == 0)