function outims = medianfilter(images)

sz = size(images);
outims = zeros(sz);

for i = 1:sz(3)
  outims(:,:,i) = medfilt2(images(:,:,i),[3 3]);
end;
