function [xf yf zf] = genUnifPts2(obj, color, ctf, cbf, nInitSpots, expFactor)

% Expand mask and 
mask = imresize(obj.object_mask.mask,expFactor);

%Generate random points filling volume xdim * ydim * max(z)

%this corresponds to maximum x value
xdim = size(mask,2)-1;

%this corresponds to max y value
ydim = size(mask,1)-1;

zdim = round(max(obj.channels.(color).spotCoordinates(:,3))*expFactor)-1;

%Fill the space with points
xn = xdim*rand(nInitSpots,1)+1;
yn = ydim*rand(nInitSpots,1)+1;

%Now mask by x,y
xr = round(xn);
yr = round(yn);

%Select only the points that fall within the mask
ind = sub2ind(size(mask),yr,xr);
inds = mask(ind)==1;
xt = xn(inds);
yt = yn(inds);

xr = xr(inds);
yr = yr(inds);

%Now we need to select only z points which are of the correct height
zn = zdim*rand(numel(xt),1)+1;

keep = zeros(size(zn));

for i = 1:numel(xr)
    if zn(i) <= ctf(yr(i),xr(i)) & zn(i) >= cbf(yr(i),xr(i))
        keep(i) = 1;
    end
end

%Convert to logicals
keep = keep > 0;

xf = xt(keep);
yf = yt(keep);
zf = zn(keep);