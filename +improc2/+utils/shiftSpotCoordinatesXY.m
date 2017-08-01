function [outX, outY] = shiftSpotCoordinatesXY(X,Y,fromChannel,toChannel,filename)
% shifts X and Y coordinates by adding on a shift correction.
% fromChannel, toChannel are e.g. 'gfp', 'cy' to shift from GFP to Cy.
% filename is a file that contains the table of shifts.
%
% For example:
% X1 = [1 2 3 4];
% Y1 = [3 4 5 6];
% 
% [X,Y] = improc2.utils.shiftSpotCoordinatesXY(X1,Y1,'alexa','cy','Scope2_2017_07_31_AllyExM.csv')
% 
% X =
% 
%     2.2296    3.2296    4.2296    5.2296
% 
% 
% Y =
% 
%     3.1840    4.1840    5.1840    6.1840


shiftTable = readtable(filename,'ReadRowNames',true);

outX = X + shiftTable{'x',[fromChannel toChannel]};
outY = Y + shiftTable{'y',[fromChannel toChannel]};

