function displayFullMethodDescriptions(obj, methodNames)
    
    if nargin < 2
        methodNames = methods(obj);
    end
    
    fullMethodDescriptions = methods(obj, '-full');
    
    fprintf('* Methods:\n');
    for i = 1:length(methodNames)
        methodName = methodNames{i};
        nomatch = cellfun(@isempty, regexp(fullMethodDescriptions, [methodName, '\(']));
        matchingLines = fullMethodDescriptions(~nomatch);
        fprintf('\t%s\n', matchingLines{:});
    end    
end
