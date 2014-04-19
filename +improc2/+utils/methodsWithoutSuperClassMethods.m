function methodNamesArray = methodsWithoutSuperClassMethods(obj, superclassMetaClass)
    methodNamesArray = methods(obj);
    superClassMethods = {superclassMetaClass.MethodList.Name};
    methodNamesArray = methodNamesArray(~ismember(methodNamesArray, superClassMethods));
end

