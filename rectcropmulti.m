function newimages = rectcropmulti(inimage,rect)
  
sz = size(inimage);

nimages = sz(3);
  
temp = imcrop(inimage(:,:,1),rect);

newimages = zeros([size(temp) nimages],class(inimage));

  
for i = 1:nimages
  newimages(:,:,i) = imcrop(inimage(:,:,i),rect);
end
