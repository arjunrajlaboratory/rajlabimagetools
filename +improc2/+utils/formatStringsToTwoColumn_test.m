improc2.tests.cleanupForTests;

strings = {'dog', 'cat', 'dinosaur', 'mouse', 'rhinoceros', 'leopard', 'bat'};

twocolumnStr = improc2.utils.formatStringsToTwoColumn(strings);

fprintf('Test of two column formatting:\n')
fprintf(twocolumnStr)

twocolumnStr = improc2.utils.formatStringsToTwoColumn(strings, 8);
fprintf('with more spaces:\n')
fprintf(twocolumnStr)
