improc2.tests.cleanupForTests;

x = improc2.utils.IdentityContraster();

im = eye(2,2);

assert(isequal(im, x.contrast(im)));

% it will also absorb any additional arguments you give it and ignore them

irrelevantArgs = {3, 'hello', struct()};
assert(isequal(im, x.contrast(im, irrelevantArgs{:})))
