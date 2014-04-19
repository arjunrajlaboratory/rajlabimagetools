improc2.tests.cleanupForTests;

figH = figure(1);

numColumns = 1;
minNumRows = 1;
buttonPositionCalculator = ...
    improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
    numColumns, minNumRows);

x = improc2.utils.ExtensiblePushButtonGroup(figH, buttonPositionCalculator);

h1 = x.makeNewButton('String', 'first button');
h1Pos = get(h1, 'Position');
assert(all(h1Pos == [0, 0, 1, 1]))

h2 = x.makeNewButton('String', 'second button');
h1Pos = get(h1, 'Position');
h2Pos = get(h2, 'Position');
assert(all(h1Pos == [0, 0.5, 1, 0.5]))
assert(all(h2Pos == [0, 0, 1, 0.5]))


figH = figure(2);

numColumns = 2;
minNumRows = 4;
buttonPositionCalculator = ...
    improc2.utils.FixedColumnsVariableRowsRectangleArrayPositionCalculator(...
    numColumns, minNumRows);

x = improc2.utils.ExtensiblePushButtonGroup(figH, buttonPositionCalculator);

h1 = x.makeNewButton('String', 'first button');
h1Pos = get(h1, 'Position');
assert(all(h1Pos == [0, 0.75, 0.5, 0.25]))

h2 = x.makeNewButton('String', 'second button');
h1Pos = get(h1, 'Position');
h2Pos = get(h2, 'Position');
assert(all(h1Pos == [0, 0.75, 0.5, 0.25]))
assert(all(h2Pos == [0.5, 0.75, 0.5, 0.25]))

for i = 1:13
    x.makeNewButton();
end

hL = x.makeNewButton('String', 'sixteenth button');

h1Pos = get(h1, 'Position');
h2Pos = get(h2, 'Position');
assert(all(h1Pos == [0, 0.875, 0.5, 0.125]))
assert(all(h2Pos == [0.5, 0.875, 0.5, 0.125]))

hLPos = get(hL, 'Position');
assert(all(hLPos == [0.5, 0, 0.5, 0.125]))
