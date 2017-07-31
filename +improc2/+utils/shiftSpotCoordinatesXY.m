function [outX, outY] = shiftSpotCoordinatesXY(X,Y,fromChannel,toChannel,filename)

shiftTable = readtable(filename,'ReadRowNames',true);

outX = X + shiftTable{'x',[fromChannel toChannel]};
outY = Y + shiftTable{'y',[fromChannel toChannel]};

