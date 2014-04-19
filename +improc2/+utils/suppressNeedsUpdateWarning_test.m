improc2.tests.cleanupForTests;


fprintf('* Check that you do not see a warning produced.\n')
[x, y] = improc2.utils.suppressNeedsUpdateWarning( ...
    @improc2.tests.returnArgumentsAndWarnNeedsUpdate, 3, 'hello');
assert(x == 3)
assert(strcmp(y, 'hello'))

originalWarningState = warning('query', 'improc2:NeedsRunOrUpdate');
assert(strcmp(originalWarningState.state, 'on'))

somethingThatThrowsError = @(x) error('improc2:IntentionalError', 'no message');

suppressWarningWhileThrowingError = @(x) ...
    improc2.utils.suppressNeedsUpdateWarning(somethingThatThrowsError, x);

try
    suppressWarningWhileThrowingError(1)
catch err
    if ~strcmp(err.identifier, 'improc2:IntentionalError')
        rethrow(err)
    end
end

assert(strcmp(originalWarningState.state, 'on'))