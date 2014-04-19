improc2.tests.cleanupForTests;

anObject = improc2.utils.DependencyRunner();

superClass = ?handle;

assert(isa(anObject, 'handle'))

superClassMethods = {superClass.MethodList.Name};

x = improc2.utils.methodsWithoutSuperClassMethods(anObject, superClass);

assert(length(x) > 0)
assert(all(~ismember(x, superClassMethods)))
