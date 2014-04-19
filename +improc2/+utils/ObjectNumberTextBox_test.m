improc2.tests.cleanupForTests;

cellArray = {[1, 2, 3], [4, 5]};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
objHolder = improc2.utils.ObjectHolder();
coreNavigator = improc2.utils.ImageObjectArrayCollectionNavigator(collection, objHolder);
navigator = improc2.tests.VerboseNavigator(coreNavigator);

figH = figure('Position', [300 300 100 100]); 
textbox = uicontrol('Style', 'edit');

assert(isempty(get(textbox, 'CallBack')))
x = improc2.utils.ObjectNumberTextBox(textbox, navigator);
assert(~isempty(get(textbox, 'CallBack')))

assert(navigator.currentObjNum == 1)
x.draw()
assert(strcmp(get(textbox, 'String'), num2str(1)))
navigator.tryToGoToObj(2);
assert(navigator.currentObjNum == 2)
% explicit draw is required to get an update.
x.draw()
assert(strcmp(get(textbox, 'String'), num2str(2)))
fprintf('* TESTER: Type a number in the box.\n If nav position and box disagree, run x.draw()\n')
