dentist.tests.cleanupForTests;

mockDisp = dentist.tests.MockDrawCountingDisplayer();

x = dentist.utils.VisibilityToggleableDisplayer(mockDisp);

assert(mockDisp.timesDrawn == 0);
x.setVisibilityAndDrawIfActive(true);
assert(x.visible)
% x not active since it hasn't been drawn yet
assert(mockDisp.timesDrawn == 0);


x.draw()
assert(mockDisp.timesDrawn == 1);
x.draw()
assert(mockDisp.timesDrawn == 2);

x.setVisibilityAndDrawIfActive(false);
assert(mockDisp.timesDrawn == 0);
x.draw()
assert(mockDisp.timesDrawn == 0);
x.draw()
assert(mockDisp.timesDrawn == 0);

x.setVisibilityAndDrawIfActive(true);
assert(mockDisp.timesDrawn == 1);
x.deactivate()
assert(mockDisp.timesDrawn == 0);

x.setVisibilityAndDrawIfActive(true);
assert(mockDisp.timesDrawn == 0)
x.draw()
assert(mockDisp.timesDrawn == 1);

figure(1); 
title('check on or off. Try x.draw() and x.deactivate() and command line')
checkUI = uicontrol('Style', 'checkbox', 'String', 'Visible');

x.attachVisibilityUIControl(checkUI);


