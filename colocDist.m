function [ D ] = colocDist( XX, YY, zAllow )
% COLOCDIST calculates the pairwise distances between points in the NX x 3
%   matrix X and NY x 3 matrix Y. This distance is euclidian in the first
%   two dimesions if the points are within zAllow planes of each other.
%       Units for X(:,1:2) are pixels and for X(:,3) are zplane ID
%       Units for Y(:,1:2) are pixels and for Y(:,3) are zplane ID

% some code adapted from pdist2

X = XX(:,1:2);
Y = YY(:,1:2);

Xz = XX(:,3);
Yz = YY(:,3);

nx = size(X, 1);
ny = size(Y, 1);

% loop through each SNP
for i = 1:ny
    
    % calculate pairwise distances of all guides with this SNP in XY
    dsq = zeros(nx,1);
    
    for q = 1:2
        
        dsq = dsq + (X(:,q) - Y(i,q)).^2;
    
    end
    
    dsq = sqrt(dsq);
    
    % filter for only those within zAllow planes
    zDiffs = abs(Xz - Yz(i,1));
    
%     disp(['zAllow: ', num2str(zAllow), ' size: ', num2str(size(zAllow))])
    
%     zAllowVec = zAllow * ones(size(zDiffs));
    
    dsq(zDiffs > zAllow, 1) = 1024^2;
    
    
    % store
    D(:,i) = dsq;
    
end




end

