dentist.tests.cleanupForTests;

figH = figure(1); axH = axes('Parent', figH); 
set(axH, 'XLim', [0 1], 'YLim', [0 1])

mockUndoButton = dentist.tests.MockEnableable();
mockResetButton = dentist.tests.MockEnableable();
mouseInterpreter = dentist.utils.RectangleDrawingInterpreter();
mockDisplayer = dentist.tests.MockVisibilityToggleable();

x = dentist.utils.DeletionsUIControlsEnabler(mockUndoButton, ...
    mockResetButton, mockDisplayer, mouseInterpreter, figH, axH);

assert(~ mockUndoButton.enabled)
assert(~ mockResetButton.enabled)
assert(~ mockDisplayer.isVisible)

title('Should not see a rectangle if you draw on here')

x.enable()

assert(mockUndoButton.enabled)
assert(mockResetButton.enabled)
assert(mockDisplayer.isVisible)

title('Should see a rectangle if you drag.')

%%

x.disable()

assert(~ mockUndoButton.enabled)
assert(~ mockResetButton.enabled)
assert(~ mockDisplayer.isVisible)

title('Should NOT see a rectangle if you drag.')

%%

x.enable()

assert(mockUndoButton.enabled)
assert(mockResetButton.enabled)
assert(mockDisplayer.isVisible)

title('Should see a rectangle if you drag.')

assert(mockDisplayer.timesDrawn == 0)
x.draw()

assert(mockDisplayer.timesDrawn == 1)
