%% imregmaxThresh
% Finds an appropriate threshold based on |imregionalmax()| pixel intensities

%% Description
% Using properties of the plot:
%
%   log(number of regional maxima remaining) vs threshold  (1)
%
% this script finds the point of transition between background and spot signal
% that is defined as the first local maxima in the first derivative of plot (1).
%
% We can then use the result as a threshold in identifying FISH spot signal 
% regional maxima above background.
%
%

%% Find the threshold that lands in the plateau of the plot
%  |
%  | -
%  |   \
%  |    |
%  |     \
%  |      -------
%  |              \
%  |                \
%   ---------------------
%    5  10  20  30  40  50 

%% How we find the number of steps 
% Objective: find appropriate number of steps where the sampled data represents 
% the trend we observe when we take the 1st & 2nd derivative. Thresholds are chosen
% where second derivative stabilizes near zero (within variance). Difficulties
% arise w/ too much discretization since this prevents using a simple definition
% of stablization.
%
% Solution: Using the knowledge we know about the steep descent (background) part
% of the plot, figure out what proportion of the plot is background. The number
% of steps is then a function of proportion of the plot as background and how
% many regional maxima we have.
% 
% So the whole function is in two-phases
%
% # Find the portion of the plot made up of background
% # Take a discrete derivative of the data to find local maxima representing the
% transition from background to signal

%% Input
% * *|mxs|* - array of |imregionalmax| values
%
% _Optional_
% 
% * *|verboseFlag|* - when true, plot info about the thresholds chosen
% 
% * *|brightSpotFlag|* - uses more stringent definition of stable threshold, good 
% for transcription sites

%% Output
% * *|threshold|* - pixel intensity to threshold the |imregionalmax| values

%% Example Usage
%  >> bw = imregionalmax(imgAT);
%  >> mxs = imgAT(bw);
%  >> threshold = imregmaxThresh(mxs);
%  >> numSpots = sum(mxs>threshold);

%% Authors
% Marshall J. Levesque 2012 (code and strategies)
%
% Gautham Nair 2012 (strategies)
%
% Arjun Raj 2012 (strategies)

function [threshold] = imregmaxThresh(varargin)
    
    %-------------------------
    % Set up input parameters
    %-------------------------
    p = inputParser;
    p.addRequired('mxs',@isnumeric)
    p.addOptional('verboseFlag',false,@islogical);
    p.addOptional('brightSpotFlag',false,@islogical);
    p.parse(varargin{:});
    mxs = p.Results.mxs;
    verboseFlag = p.Results.verboseFlag;
    brightSpotFlag = p.Results.brightSpotFlag;
    minSteps = 30;
    threshold = [];
    

    %----------------------------------------------------------------
    % Phase-1: Find the proportion of the signal that is "background"
    %----------------------------------------------------------------
    % Regional maxima due to background intensities produce a consistent
    % sharp drop off in the cumulative distribution curve:
    %    log(remaining number of spots) vs threshold 
    % The objective here is to examine just this region of the curve to
    % find the line that approximates this descent. Using the line, we
    % can approximate what proportion of the cumulative distribution is
    % produced by background.
    mxsS = scale(mxs);  % use 0-1 scaled image
    steps = minSteps*log10(numel(mxs)); % aim to get 50-200 steps, more for more mxs
    if steps < minSteps; steps = minSteps; end;
    center = mean(mxsS);
    width = std(mxsS);
    left = 0; right = center+6*width;
    if right >1; right = 1; end;
    rng = right - left;
    ss = rng/steps;
    numMx = [];
    thresholds = [left:ss:right];
    for k = thresholds;
        numMx = [numMx numel(find(mxsS>k))];
    end
    bkgdRatio = backgroundRatio(thresholds,numMx,ss,verboseFlag);
    if isempty(bkgdRatio)
        return;
    end
    

    %------------------------------------------------------------------
    % Phase-2: Find the "plateau" in log(number of spots) vs threshold
    %------------------------------------------------------------------
    left = 0;
    right = max(mxs);
    steps = log(sum(mxs>left))/bkgdRatio;
    if steps < minSteps  
        steps = minSteps;
    elseif steps > 200
        steps = 200;
    end
    rng = right - left;
    ss = rng/steps;
    numMx = [];
    thresholds = [left:ss:right];

    for k = thresholds;
        numMx = [numMx numel(find(mxs>k))];
    end

    lgMx = log(numMx);
    numMxD = gradient(smoothenCDF(lgMx),ss);  % first derivative
    numMxDD = gradient(numMxD);  % second derivative

    % first stable point (at the "plateau")
    zC = zCross(numMxDD,'plus_minus');  % find local maxima

    % VERY FLAT ZERO stable for two point, good for intron spots
    flatInds = (numMxD(1:end-1) == 0) + (numMxD(2:end) == 0);
    flatInds = find(flatInds>1);

    if brightSpotFlag  % force a truly FLAT LINE plateau
        if ~isempty(flatInds)   % flat line for FEW BRIGHT spots
            threshold = thresholds(flatInds(1));
        else
            threshold = [];  % no FLAT LINE spots
            return;
        end
    else   % finding RNA spots of normal intensity
        if ~isempty(zC)
            threshold = thresholds(zC(1)); % first local maxima in first derivative
        elseif ~isempty(flatInds)   % backup threshold, flat line for BRIGHT spots
            threshold = thresholds(flatInds(1));
        else
            threshold = [];  % no spots
            return;
        end
    end

    if verboseFlag
        %figure; plot(thresholds,numMxDD);
        %figure; plot(thresholds,numMxD);
        figure; plot(thresholds,lgMx);
        xlabel('Threshold values','FontSize',14);
        ylabel('log(number of spots remaining)','FontSize',14);
    end

    if verboseFlag
        hold on; plot([threshold threshold],[0 max(lgMx)],'g'); 
        legend('log(number of spots) vs Threshold','Chosen Threshold');
        hold off; drawnow;
    end

function resultcdf = smoothenCDF(cdf)
    usersMatlabInstallHasSmooth = (exist('smooth', 'file') == 2);
    
    if usersMatlabInstallHasSmooth
        resultcdf = smooth(cdf);
    else
        resultcdf = cdf;
    end
    

function [bkgdRatio] = backgroundRatio(thresholds,numMx,ss,verboseFlag)
% Analyzes the plot of log(number of remaining maxima) VS intensity threshold 
% to identify the exponential descent background and calculates the proportion
% of background to the total regional max intensities. 

    lgMx = log(numMx);  % log(number of remaining maxima)
    lgMxD = gradient(smoothenCDF(lgMx),ss);  % 1st derivative, the slope
    lgMxDD = gradient(lgMxD,ss); % 2nd derivative 
    zcInds = zCross(lgMxDD,'minus_plus');  % zCross for most negative slope 
    zcInd = zcInds(1);  % first minus-to-plus zero cross 

    % Calculate the line going through the steepest decent point
    %    y = m*x + b  % eqn of a line
    %    b = y - m*x; % calc the y-intercept
    b = lgMx(zcInd) - lgMxD(zcInd)*thresholds(zcInd);  % find the y-intercept
    y = lgMxD(zcInd) .* thresholds + b;  % calculate the line itself for plotting

    % Find how much of the line is < 1 away from the data
    bkgdInds = abs(y-lgMx) < 1;
    bkgdIntensityVals = thresholds(bkgdInds);
    bkgdRatio = range(bkgdIntensityVals);
    
    zcVal = thresholds(zcInd);

    lastB = thresholds(bkgdInds(end));
    lastNumX = numMx>0;
    if y(end) > lgMx(lastNumX(end)) | bkgdRatio > 0.5
    % background is greater than the number of maxes at last threshold with data
    % OR the background ratio is greater than 50% of all thresholds
        bkgdRatio = []; % aka No Spots!
    end

    if verboseFlag
        figure; plot(thresholds,lgMx,'b');
        hold on;
        plot(thresholds,y,'r');
        plot(repmat(min(bkgdIntensityVals),[1 2]),[0 max(lgMx)],'g');
        plot(repmat(max(bkgdIntensityVals),[1 2]),[0 max(lgMx)],'g');
        ylim([0 max(lgMx)]);
        xlabel('Threshold values','FontSize',14);
        ylabel('log(Number of spots remaining)','FontSize',14);
        legend('log(NumSpots) vs Threshold','Background Fit','Background Region');
        hold off;
    end

function zcInds = zCross(y,direction)
% find the zeros crosses, specifying whether it goes from positive to minus
% or minus to positive

    posInds = y > 0;
    negInds = y < 0;
    if strcmp(direction,'plus_minus')
        zcInds = posInds(1:end-1) & negInds(2:end);
    elseif strcmp(direction,'minus_plus')
        zcInds = negInds(1:end-1) & posInds(2:end);
    end
    zcInds = find(zcInds);
    
