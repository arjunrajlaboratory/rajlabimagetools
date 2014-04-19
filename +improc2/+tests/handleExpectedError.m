function handleExpectedError(err, expectedErrId )
    
    if nargin < 2
        if ~strcmp(err.identifier, 'improc2:ErrorNotProduced')
            fprintf('Triggered error as expected:\n %s\n', err.message)
        else
            rethrow(err)
        end
    else
        if strcmp(err.identifier, expectedErrId)
            fprintf('Triggered %s error as expected:\n%s\n', ...
                err.identifier, err.message)
        else
            rethrow(err)
        end
    end
end

