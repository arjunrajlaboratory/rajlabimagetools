dentist.tests.cleanupForTests;

polygonStack = dentist.utils.PolygonStack();

poly1 = [10 10; 10 20; 20 15];
polygonStack.addPolygon(poly1);
poly2 = [30 20; 30 25; 35 25; 35 20]; 
polygonStack.addPolygon(poly2);

figH = figure(1); axH = axes('Parent', figH);
set(axH, 'XLim', [0 100], 'YLim', [0 100])

x = dentist.utils.PolygonsDisplayer(axH, polygonStack);

x.draw();

polygonStack.removeLastPolygon();

x.draw();
