function deltaXY = getDeltaXY(spots1,spots2)

D = pdist2(spots1,spots2);
M = zeros(size(D));
M(D<4) = 1;

deltaXY = spots2-M'*spots1; % This is the relevant difference.
