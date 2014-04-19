improc2.tests.cleanupForTests;

img = uint8([1 2 3]);
[scaledIm, minAndMax] = improc2.utils.scale(img);

assert(isa(scaledIm, 'single'))
assert(all(scaledIm == [0 0.5 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [1 3]))

img = uint16([1 2 3]);
[scaledIm, minAndMax] = improc2.utils.scale(img);

assert(isa(scaledIm, 'single'))
assert(all(scaledIm == [0 0.5 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [1 3]))

img = single([1 2 3]);
[scaledIm, minAndMax] = improc2.utils.scale(img);

assert(isa(scaledIm, 'single'))
assert(all(scaledIm == [0 0.5 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [1 3]))

img = double([1 2 3]);
[scaledIm, minAndMax] = improc2.utils.scale(img);

assert(isa(scaledIm, 'double'))
assert(all(scaledIm == [0 0.5 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [1 3]))

%

img = uint16([1 2 3]);
[scaledIm, minAndMax] = improc2.utils.scale(img, [2 3]);

assert(isa(scaledIm, 'single'))
assert(all(scaledIm == [0 0 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [2 3]))

[scaledIm, minAndMax] = improc2.utils.scale(img, [1 2]);

assert(isa(scaledIm, 'single'))
assert(all(scaledIm == [0 1 1]))
assert(isa(minAndMax, 'double'))
assert(all(minAndMax == [1 2]))
