%% separableConv
% Performs separable convolution of 2D/3D image one dimension at a time
% that ends up the same as doing a full convolution with a 2D/3D/ND kernel
% This is only true for separable kernels. Be sure it applies... 

%% Input
% * *|img|* : the image to be smoothed with a Gaussian kernel 
%
% +1 Input
% * *|kernel|* - a 1D kernel to be applied to the input image/signal
%
% +2 Inputs
% * *|kernelWidth|*: the desired width of the kernel
% * *|sigmaWidth|*: the width of the Gaussian

%% Output
% * *|img|* : the smoothed image (we don't create a new variable to hopefully save 
% on time required for associated memory I/O)

%% Author
% Marshall J. Levesque 2011

function [img] = separableConv(img,varargin)

boundary = 'replicate';  % set default value for out of index as the boundary
outputSize = 'same';
if nargin == 3
    % calculate a 1D gaussian kernel
    kernelWidth = varargin{1};
    sigmaWidth = varargin{2};
    kernel = fspecial('gaussian',[1 kernelWidth],sigmaWidth);
elseif nargin == 2
    sigmaWidth = 1;
    kernel = varargin{1};
elseif nargin == 4   % here we can mimic using convn 
    sigmaWidth = 1;
    kernel = varargin{1};
    outputSize = varargin{2};  % 'same' or 'full'  
    boundary = varargin{3};  % zero is a what |convn()| uses
else
    sigmaWidth = 1;
    kernel = fspecial('gaussian',[1 5],1.09);
end

if sigmaWidth > 0 
    % figure out the dimensions of our image
    [M,N,P] = size(img);


    % Convolve the image in the x-direction first.
    img = imfilter(img,kernel,boundary,outputSize,'conv');

    if N > 1
    % the 1D kernel in the Y-direction
    kernel = permute(kernel,[2 1]);
    img = imfilter(img,kernel,boundary,outputSize,'conv');
    end

    if P > 1
    % the 1D kernel in the Z-direction.
    %kernel = permute(kernel,[3 2 1]);
        kernel = reshape(kernel,[1 1 length(kernel)]);
        img = imfilter(img,kernel,boundary,outputSize,'conv');
    end
else
    return
end

