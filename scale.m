%% scale
% Adjust the contrast of an image using the max/min voxel intensities

%% Description 
% Image scaling in its simplest form can be as follows:
% 
% * find the minimum intensity value of the image
% * substract the minimum intensity value from all voxels
% * find the maximum intensity value of the new image
% * for all voxels, divide by the max intensity value
%
% Division/Multiplication is not allowed in MATLAB when using INTEGER class data.
% This script aims to avoid conversion to double() that requires 4X the memory where
% 50MB images become 200MB. MATLAB also can be slow allocating this much memory. 
% We compromise by using single() (2X memory) with integer inputs

%% Input
% *|img|* - the image
%
% _Optional_
%
% *|intensityScale|* - set the minimum and maximum voxel intensity values (aka *CONTRAST*) 

%% Output
% *|img|* - the scaled image
%
%% Example Usage:
%  >> im = readmm('cy001.stk',10);  % read plane #10 in image stack
%  >> imshow(im.imagedata);  % unscaled image (UINT16)
%  >> imS = scale(im.imagedata);   % scale only within plane #10 of image stack
%  >> imshow(imS)   % scaled image  (UINT16)
%
%  >> A1 = readmm('alexa001.stk');  
%  >> A1S = scale(A1.imagedata);   % scale for entire 3D image stack
%  >> imshow(A1S(:,:,10))   % scaled image  (UINT16)
%
%  >> A1 = readmm('alexa001.stk');   % [min max] = [800 2500]
%  >> A1contrast = scale(A1.imagedata,'intensityScale',[700 3000]); % define a desired contrast
%  >> A1thresh = scale(A1.imagedata,'intensityScale',[1200 2100]); % threshold image using clipping

%% Author
% Marshall J. Levesque 2011-2012

function img = scale(img,varargin)

%-----------------------------
% Process our input arguments
%-----------------------------
p = inputParser;
p.addRequired('img',@(x) (isa(x,'integer') || isa(x,'float')));
validRange = @(x)validateattributes(x,{'numeric'},{'2d'},'Scale/Clipping Definition');
p.addOptional('intensityScale',[], validRange);
p.parse(img,varargin{:});

img = p.Results.img;
intensityScale = double(p.Results.intensityScale);  % MATLAB's friendly double
if ~isempty(intensityScale) && ...
        (~issorted(intensityScale) || numel(intensityScale) ~= 2)
    error('Scale definition must be in the form: [minIntensity maxIntensity]');
end
lowerClippingFlag = false;
upperClippingFlag = false;

% if less than double-precision, keep a lower memory footprint using float
% single precision since we the likely integer input will not have such precision.
% Division needs floating point to avoid rounding, single() takes half the memory
if ~isa(img,'double') 
    img = single(img);
end
origMin = min(img(:));
origMax = max(img(:));

% * find the minimum intensity value of the image
imgMin = origMin;
if ~isempty(intensityScale)
    if intensityScale(1) <= origMin  % reduce contrast by lowering minimum
        adj = abs(imgMin - intensityScale(1));
        img = img+adj;
        intensityScale(2) = intensityScale(2) + adj;
    else
        lowerClippingFlag = true;
    end
    imgMin = intensityScale(1);
end

% adjust minimum intensity to zero
img = img - imgMin;

% * find the maximum intensity value of the new image
if ~isempty(intensityScale)
    if intensityScale(2) < origMax
        upperClippingFlag = true;
    end
    imgMax = intensityScale(2)-imgMin;
else        
    imgMax = max(img(:));
end
% * for all voxels, divide by the max intensity value
img = img ./ imgMax;

% Clipping
if lowerClippingFlag 
    img(img<0) = 0;
end
if upperClippingFlag
    img(img>1) = 1;
end

