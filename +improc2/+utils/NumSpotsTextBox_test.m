improc2.tests.cleanupForTests;

figH = figure('Position', [300 300 100 100]); 
textbox = uicontrol('Style', 'text');

fakeNumSpotsProvidingProcessor = struct();
fakeNumSpotsProvidingProcessor.getNumSpots = @() 5;

fakeProcessorDataHolder = struct();
fakeProcessorDataHolder.processorData = fakeNumSpotsProvidingProcessor;

x = improc2.utils.NumSpotsTextBox(textbox, fakeProcessorDataHolder);

x.draw()

assert(strcmp(get(textbox, 'String'), num2str(5)))
