function [shell, shell_filt] = calcShell2(croppedMask,x,y,z,expFactor,filtersize)

resizedMask = imresize(croppedMask, expFactor);

x2 = x;%*expFactor;
y2 = y;%*expFactor;
z2 = z;%*expFactor;

%disp('triscatteredinterp');
F = TriScatteredInterp(x2,y2,z2);

ti = 1:size(resizedMask,1);
tf = 1:size(resizedMask,2);
[qx,qy] = meshgrid(tf,ti);
%disp('shell');
shell = F(qx,qy);
%disp('shellfilt');
shell_filt = medfilt2(shell,[filtersize filtersize]);
%disp('done with shellfilt');