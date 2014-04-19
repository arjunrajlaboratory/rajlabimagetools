improc2.tests.cleanupForTests;

g = improc2.fitting.Gaussian2dSpot(0, -1, 3.3, 4);

assert(g.xCenter == 0)
assert(g.yCenter == -1)
assert(g.sigma == 3.3)
assert(g.amplitude == 4)

% default value of Z
assert(g.zPlane == 1)

g = improc2.fitting.Gaussian2dSpot(0, 0, 1, 1);

assert(g.valueAt(0,0) == 1)

Xs = [1, -1, 0, 0];
Ys = [0, 0, 1, -1];
assert(all(size(g.valueAt(Xs,Ys)) == size(Xs)))
assert(all(g.valueAt(Xs, Ys) == exp(-1/2)))

Xs = [1, -1, 0, 0]';
Ys = [0, 0, 1, -1]';
assert(all(size(g.valueAt(Xs,Ys)) == size(Xs)))
assert(all(g.valueAt(Xs, Ys) == exp(-1/2)))


Xs = [1, 1, -1, -1];
Ys = [1, -1, 1, -1];
assert(all(g.valueAt(Xs, Ys) == exp(-1)))

Xs = [-1 0 1;
    -1 0 1;
    -1 0 1];
Ys = [0 0 0;
    -1 -1 -1;
    -2 -2 -2];

img = g.valueAt(Xs,Ys);
assert(all(size(img) == size(Xs)))

assert(img(1,2) == 1)
assert(all([img(1,1), img(1,3), img(2,2)] == exp(-1/2)))
assert(all([img(2,1), img(2,3)] == exp(-1)))
assert(all([img(3,2)] == exp(-4/2)))
assert(all([img(3,1), img(3,3)] == exp(-5/2)))


g = improc2.fitting.Gaussian2dSpot(0, 0, 3, 1);

assert(g.valueAt(0,0) == 1)
assert(g.valueAt(1,0) == exp(- 1/ (3^2) /2))

g = improc2.fitting.Gaussian2dSpot(0, 0, 1, 1/2);
assert(g.valueAt(0,0) == 1/2)
assert(g.valueAt(1,0) == 1/2 * exp(-1/2))

% testing zPlane functionality

zPlane = 5;
g = improc2.fitting.Gaussian2dSpot(0, 0, 1, 1, 5);

% if no z requested, gives value in spot's own plane
assert(g.valueAt(0,0) == 1)


assert(g.valueAt(0,0,1) == 0)
assert(g.valueAt(0,0,2) == 0)
assert(g.valueAt(0,0,5) == 1)
assert(g.valueAt(0,0,6) == 0)

Xs = [1, -1, 0, 0];
Ys = [0, 0, 1, -1];
assert(all(size(g.valueAt(Xs,Ys)) == size(Xs)))
assert(all(g.valueAt(Xs, Ys) == exp(-1/2)))

assert(all(size(g.valueAt(Xs, Ys, 1)) == size(Xs)))
assert(all(g.valueAt(Xs, Ys, 1) == 0))

assert(all(size(g.valueAt(Xs, Ys, 5)) == size(Xs)))
assert(all(g.valueAt(Xs, Ys, 5) == exp(-1/2)))

% testing working with an array of these.

g1 = improc2.fitting.Gaussian2dSpot(0,0, 1, 1);
g2 = improc2.fitting.Gaussian2dSpot(0,0, 1, 2);

gArray = [g1, g2];

assert(all([gArray.amplitude] == [1, 2]))
