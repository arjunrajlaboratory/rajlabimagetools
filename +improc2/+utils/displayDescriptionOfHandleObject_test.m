improc2.tests.cleanupForTests;

aHandleObject = improc2.utils.DependencyRunner();

fprintf('Begin test of description displayer applied to a particular handle object:\n\n')
improc2.utils.displayDescriptionOfHandleObject(aHandleObject);

fprintf('\nSome useful description should have printed above\n')
