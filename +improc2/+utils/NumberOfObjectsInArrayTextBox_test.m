improc2.tests.cleanupForTests;

cellArray = {[10, 20, 30], 40};
collection = improc2.utils.InMemoryObjectArrayCollection(cellArray);
objHolder = improc2.utils.ObjectHolder();
navigator = improc2.utils.ImageObjectArrayCollectionNavigator(...
    collection, objHolder);

figH = figure('Position', [300 300 100 100]); 
textbox = uicontrol('Style', 'text');


x = improc2.utils.NumberOfObjectsInArrayTextBox(textbox, navigator);
x.draw()

fprintf('textbox should say ''Obj: (newline) of 3''\n')
