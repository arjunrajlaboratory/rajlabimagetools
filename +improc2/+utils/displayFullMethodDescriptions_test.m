improc2.tests.cleanupForTests;

objToDescribe = improc2.utils.DependencyRunner();

fprintf('\nLong list of all methods:\n')
improc2.utils.displayFullMethodDescriptions(objToDescribe)
fprintf('\nShort list of selected methods:\n')
improc2.utils.displayFullMethodDescriptions(objToDescribe, ...
    {'runDependencies', 'registerDependency'})