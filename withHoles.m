%% withHoles
% modify a 1D kernel (eg B3-spline) for use in the "á trous wavelet transform"

%% Description
% Given the 1D kernel [1 2 3 2 1], for a scale level (j) insert 2^(j-1)-1 zeros between
% the taps in the the kernel. For example:
%
% For j=2, [1 2 3 2 1] becomes [1 0 2 0 3 0 2 0 1]   
%
% For j=3, [1 2 3 2 1] becomes [1 0 0 0 2 0 0 0 3 0 0 0 2 0 0 0 1]   

%% Input
% * *|kernel|* - a 1D kernel that will have "á trous" applied to it
%
% * *|scaleLevel|* - an integer that specifies how to modify |kernel|, see description

%% Output
% * *|kernel|* - the modified kernel, still 1D

%% Works Cited
% * Starck and Murtagii et al. Multiresolution support applied to image filtering and
% restoration. Graphical models and image processing (1995)
%
% * Olivo-Marin. Extraction of spots in biological images using multiscale products.
% Pattern Recognition (2002)

%% Author
% Marshall J. Levesque 2011

function kernel = withHoles(kernel,scaleLevel)

    % we use informative variable names as input arguments only
    j = scaleLevel;
    h = kernel;

    % at each level |j|, insert 2^(j-1) - 1 zeros between taps in the original kernel |h|
    insert = 2^(j-1) -1;
    fillup = zeros(1,insert);
    kernel = [];
    for i = 1:length(h)-1
        kernel = [kernel h(i) fillup];
    end
    kernel = [kernel h(end)];

