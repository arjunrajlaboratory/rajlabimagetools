function [volume, celltop, cellbottom] = findVol_Expand2(croppedMask, dapiMask, ...
        x, y, z, expFactor, radius)

filtersize = 30;

resizedMask = imresize(croppedMask, expFactor);

resizedDapiMask = imresize(dapiMask, expFactor);

points = [x y z];

R = radius * expFactor;

goodpts = zeros(size(x));

for i = 1:length(x)
    %disp(i);
    currpt = points(i,:);
    for j = 1:length(x)
        dist(j) = norm(points(j,1:2)-currpt(1:2));
    end;
    ind = dist < R;  % Find all points whos XY distance is < R from currpt
    ind(i) = 0;  % Remove currpt from the list, since we aren't worried about that one.
    
    temppts = points(ind,:);
    sz = size(temppts);
    for j = 1:sz(1)
        temppts(j,:) = temppts(j,:)-currpt;
        %        temppts(j,1:2) = temppts(j,1:2)/norm(temppts(j,1:2));
    end;
    
    ind = temppts(:,3) > 0;
    if sum(ind) == 0
        goodpts(i) = 1;
    else
        
        temppts2 = temppts(ind,:);
        
        [theta, rho] = cart2pol(temppts2(:,1),temppts2(:,2));
        th = sort(theta);
        th = [th ; th(1)+2*pi];  % circularize
        maxdiff = max(diff(th));
        if maxdiff > pi
            goodpts(i) = 1;
        end;
    end;
    
    zs = temppts(:,3);  % relative Z coordinates of all neighbors (to currpt)
    if min(abs(zs)) > 5*expFactor  % remove hot pixels
        goodpts(i) = 0;
    end;
    
end;

goodpts = goodpts>0;  % Convert to logical

x2t = x(goodpts);
y2t = y(goodpts);
z2t = z(goodpts);

[celltop, celltop_filt] = improc2.volume.calcShell2(croppedMask,x2t,y2t,z2t,expFactor,filtersize);

%Now repeat for the bottom of the cell

goodpts = zeros(size(x));

for i = 1:length(x)
    currpt = points(i,:);
    for j = 1:length(x)
        dist(j) = norm(points(j,1:2)-currpt(1:2));
    end;
    ind = dist < R;  % Find all points whos XY distance is < R from currpt
    ind(i) = 0;  % Remove currpt from the list, since we aren't worried about that one.
    
    temppts = points(ind,:);
    sz = size(temppts);
    for j = 1:sz(1)
        temppts(j,:) = temppts(j,:)-currpt;
        %        temppts(j,1:2) = temppts(j,1:2)/norm(temppts(j,1:2));
    end;
    
    ind = temppts(:,3) < 0;
    if sum(ind) == 0
        goodpts(i) = 1; %keep this point if there are no lower points
    else
        
        temppts2 = temppts(ind,:);
        
        [theta,rho] = cart2pol(temppts2(:,1),temppts2(:,2));
        th = sort(theta);
        th = [th ; th(1)+2*pi];  % circularize
        maxdiff = max(diff(th));
        if maxdiff > pi
            goodpts(i) = 1;
        end;
    end;
    
    zs = temppts(:,3);  % relative Z coordinates of all neighbors (to currpt)
    if min(abs(zs)) > 5  % remove hot pixels
        goodpts(i) = 0;
    end;
    
end;

goodpts = goodpts>0;  % Convert to logical

x2b = x(goodpts);
y2b = y(goodpts);
z2b = z(goodpts);

[cellbottom, cellbottom_filt] = improc2.volume.calcShell2(croppedMask,x2b,y2b,z2b,expFactor,filtersize);

height = celltop_filt - cellbottom_filt;
height(isnan(height)) = 0;
height(~resizedMask) = 0;
height(resizedDapiMask) = 0;
volume = sum(height(:));