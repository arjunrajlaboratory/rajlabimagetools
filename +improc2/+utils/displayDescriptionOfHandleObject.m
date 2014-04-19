function displayDescriptionOfHandleObject(obj)
    fprintf('* Class:\n')
    fprintf('\t%s\n', class(obj));
    
    fprintf('* Properties:\n')
    propertyNames = properties(obj);
    fprintf(improc2.utils.formatStringsToTwoColumn(propertyNames));
    
    methodNames = improc2.utils.methodsWithoutSuperClassMethods(obj, ?handle);
    
    methodNames = tryToExcludeConstructorFromList(methodNames, obj);
    
    fullMethodDescriptions = methods(obj, '-full');
    
    fprintf('* Methods:\n');
    for i = 1:length(methodNames)
        methodName = methodNames{i};
        nomatch = cellfun(@isempty, regexp(fullMethodDescriptions, [methodName, '\(']));
        matchingLines = fullMethodDescriptions(~nomatch);
        fprintf('\t%s\n', matchingLines{:});
    end
    
    
    
end

function out = tryToExcludeConstructorFromList(in, obj)
    classNameWithoutFullPackageAddress = regexp(class(obj), '[^.]*$', 'match');
    out = in(~strcmp(in, classNameWithoutFullPackageAddress));
end
