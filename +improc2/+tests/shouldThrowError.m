function shouldThrowError(zeroArgFuncThatShouldThrowError, expectedErrId )
    try
        zeroArgFuncThatShouldThrowError();
        error('Expected An Error')
    catch err
        if nargin == 2
            if ~ strcmp(err.identifier, expectedErrId)
                rethrow(err)
            end
        else
            if strcmp(err.message, 'Expected An Error')
                rethrow(err)
            end
        end
        fprintf('Triggered error as expected:\n%s\n', err.message)
    end
end
