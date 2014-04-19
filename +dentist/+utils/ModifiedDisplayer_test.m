dentist.tests.cleanupForTests;

paramsHolder = dentist.utils.CentroidsNumSpotsParametersHolder('FontSize', 12);

a = dentist.tests.MockParameterGrabbingDisplayer(paramsHolder, 'FontSize');
a.draw()
assert(a.timesDrawn == 1)
assert(a.paramGrabbedOnDraw == 12)


x = dentist.utils.ModifiedDisplayer(a, paramsHolder, 'FontSize', 20);
y = dentist.utils.ModifiedDisplayer(a, paramsHolder, 'FontSize', 6);

x.draw()
assert(a.timesDrawn == 2)
assert(a.paramGrabbedOnDraw == 20)
assert(paramsHolder.get('FontSize') == 20)

y.draw()
assert(a.timesDrawn == 3)
assert(a.paramGrabbedOnDraw == 6)
assert(paramsHolder.get('FontSize') == 6)

x.deactivate()
assert(a.timesDeactivated == 1)

