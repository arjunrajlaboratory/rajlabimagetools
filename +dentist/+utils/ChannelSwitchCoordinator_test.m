dentist.tests.cleanupForTests;

channelNames = {'cy', 'tmr', 'dapi'};
x = dentist.utils.ChannelSwitchCoordinator(channelNames);
assert(all(strcmp(x.channelNames, channelNames)))

a = dentist.tests.MockChannelGrabbingDisplayer(x, 'A');
b = dentist.tests.MockChannelGrabbingDisplayer(x, 'B');
c = dentist.tests.MockChannelGrabbingDisplayer(x, 'C');

x.addActionAfterChannelSwitch(a, @draw);
x.addActionAfterChannelSwitch(b, @draw);
x.addActionAfterChannelSwitch(c, @draw);
%%

x.setChannelName('tmr');
assert(all(strcmp({a.channelGrabbedOnDraw, b.channelGrabbedOnDraw, ...
    c.channelGrabbedOnDraw}, 'tmr')))
%%
x.setChannelName('dapi');
assert(all(strcmp({a.channelGrabbedOnDraw, b.channelGrabbedOnDraw, ...
    c.channelGrabbedOnDraw}, 'dapi')))


figH = figure(1);
ui = uicontrol('Parent',figH, 'Style','popup', 'String', 'null', ...
    'Units', 'normalized', 'Position', [0.1 0.1 0.4 0.3]);

x.attachUIControl(ui);
assert(all(strcmp(get(ui, 'String'), x.channelNames(:))))
assert(strcmp(x.channelNames{get(ui, 'Value')}, 'dapi'))
x.setChannelName('tmr')
assert(all(strcmp(get(ui, 'String'), x.channelNames(:))))
assert(strcmp(x.channelNames{get(ui, 'Value')}, 'tmr'))

title('Click on different channels and notice that a,b,c are switched too')
