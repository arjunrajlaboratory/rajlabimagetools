improc2.tests.cleanupForTests;

figH = figure(1);axH = axes('Parent', figH, 'Color', 'k');
set(axH, 'XLim', [0 10], 'YLim', [0 10])

J = [3, 7, 5];
I = [2, 2, 8];
K = [1, 2, 3];

mockSpots = improc2.tests.MockSpotCoordinatesProvider(I, J, K);

x = improc2.utils.SpotsDisplayer(axH, mockSpots);
x.draw()
assert(~isempty(get(axH, 'Children')))
x.deactivate()
assert(isempty(get(axH, 'Children')))

x.draw()
hold on;
scatter(J, I, '.r')
