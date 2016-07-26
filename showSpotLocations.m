function showSpotLocations(spots, z, colMarker)

% imslice = im(:,:,z);
%imslice = max(imslice,[],3);

% zcoords = spots(:,3)/zDeform;
% zcoords = spots(:,3) / (zStepSize/xyPixelDistance);
zcoords = spots(:,3);

brightspots = spots(find(zcoords == z),:);
dimspots    = spots(find(zcoords == (z-1) | zcoords == (z+1)),:);
% 
% hold off;
% imshow(imslice,[]);
% hold on;
plot(   dimspots(:,1),    dimspots(:,2), colMarker,'markersize',20)
plot(brightspots(:,1), brightspots(:,2), colMarker,'markersize',20,'LineWidth',3)

