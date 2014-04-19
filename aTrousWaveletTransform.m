%% aTrousWaveletTransform
% 

%% Input
% * *|img|* - image or other signal (1D/2D/3D) to apply the transform
%
% _Optional_ `default`
% * *|numLevels|* - number of detail bands (scales) for the transform  `3`
%
% * *|sigma|* - sigma with of the starting kernel  `0.5`
%
% * *|VST|* - variance stabilizing transform parameters, no VST if empty `[]`
%
% * *|denoiseFDR|* - false discovery rate used in denoising each detail band `[]`

%% NOTES
% * Warning: the á trous wavelet transform has high memory requirements 
% equal to about numLevels * sizeof(img)

%% References
% * Olivo-Marin. Extraction of spots in biological images using multiscale products.
% Pattern Recognition (2002)
% 
% * Starck and Fadili. The undecimated wavelet decomposition and its reconstruction.
% Image Processing (2007)
%
% * Zhang et al. Multiscale variance-stabilizing transform for mixed-Poisson-Gaussian 
% processes and its applications in bioimaging. … Processing (2007)
% 
% * Zhang et al. Wavelets, ridgelets, and curvelets for Poisson noise removal. 
% Image Processing, IEEE Transactions on (2008) vol. 17 (7) pp. 1093-1108

%% Author
% Marshall J. Levesque 2011-2012

function [aTrous,Aj] = aTrousWaveletTransform(varargin)

    p = inputParser;
    p.addRequired('img',@isnumeric);
    p.addOptional('numLevels',3,@(x) x>1 && x < 10);
    p.addOptional('sigma',0.5,@(x) x>.1 && x<5);
    p.addOptional('width',5,@(x) x>=3 && x<25);
    p.addOptional('VST',[],@isstruct);
    p.addOptional('denoiseFDR',[],@(x) x<1 && x>0);
    p.parse(varargin{:});
    img = p.Results.img;
    numLevels = p.Results.numLevels;
    sigma = p.Results.sigma;
    width = p.Results.width;
    VST = p.Results.VST;
    FDR = p.Results.denoiseFDR;


VSTFlag = false;
if isempty(VST)
    h = fspecial('gaussian',[1 width],sigma);
else
    VSTFlag = true;
    if length(VST.Bs) ~= numLevels+1
        error('Precomputed VST parameters do not match provided input');
    end
    h = VST.h;
    Bs = VST.Bs;
    Cs = VST.Cs;
    Vs = VST.Vs;
    if isempty(varargin)
        FDR = 1e-6;
    elseif length(varargin) == 1
        FDR = varargin{1};
    end
end

denoiseFlag = false;
if ~isempty(FDR)
    if ~VSTFlag 
        fprintf(1,'NOTICE: Cannot denoise without VST parameters!\n')
    end
    denoiseFlag = true;
end

% Work in single-precision without image class constraints on the pixel values
% since it is possible to have negative numbers, values > class maximum 
img = single(img);

[M,N,P] = size(img);

if P>1
    aTrous = zeros(M,N,P,numLevels,class(img)); % create 4D matrix to store the transform
    sigDims = 3;
elseif N>1
    aTrous = zeros(M,N,numLevels,class(img));   % create 3D matrix to store the transform
    sigDims = 2;
else
    aTrous = zeros(M,numLevels,class(img));     % create 2D matrix to store the transform
    sigDims = 1;
end

Aj = img;  % the initial (zero) level detail image

for j = 2:numLevels+1  % MATLAB is 1-indexed instead of ZERO
    kernel = withHoles(h,j-1);
    
    Ao = Aj;
    Aj = separableConv(Ao,kernel); % perform the SEPARABLE convolution
    if VSTFlag
        Anew = vstOperator(Ao,j-1,Bs,Cs) - vstOperator(Aj,j,Bs,Cs);
    else
        Anew = Ao-Aj;  % generate the wavelet coefficient for this level
    end

    if denoiseFlag && VSTFlag
        Anew = denoise(Anew,FDR,Vs(j));
    end
    
    % perform a check of the input image/signal (1D v 2D v 3D?) so we know 
    % how to store it
    if P>1      % 3D image
        aTrous(:,:,:,j-1) = Anew;  % store it in a 4D matrix 
    elseif N>1  % 2D image
        aTrous(:,:,j-1) = Anew;    % store it in a 3D matrix 
    else    % should be a 1D signal
        aTrous(:,j-1) = Anew;      % store it in a 2D matrix 
    end
end

if VSTFlag; Aj = vstOperator(Aj,j,Bs,Cs); end;

