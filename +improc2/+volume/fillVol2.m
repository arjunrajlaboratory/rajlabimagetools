function [xf, yf, zf] = fillVol2(croppedMask, spotZCoords, ctf, cbf, nRealSpots, expFactor)

% Resize cell top, bottom
ctf = imresize(ctf,expFactor);
ctf = ctf*expFactor;
cbf = imresize(cbf,expFactor);
cbf = cbf*expFactor;

[xf, yf, zf] = improc2.volume.genUnifPtsExact(croppedMask, spotZCoords, ctf, cbf, nRealSpots, expFactor);