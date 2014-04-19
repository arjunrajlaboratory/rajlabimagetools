%% aTrousGaussFits
% Identifies spot candidates using workflow in |aTrousRegionalMaxProc|, but also
% fits a 2D gaussian function to the spots to find their sub-pixel centers.

%% Description
% This processor has 4 main tasks in the |run()| method:
% 
% # Use the aTrous wavelet transform to deconstruct the input image into multiple
% levels of detail. A property of the undecimated aTrous wavelet transform that we 
% use is that the original image can be reconstructd by summing the detail images. 
% This step reconstructs the image using only the first 3 detail levels for a given
% sigma used as the kernel in the aTrous process. See |aTrousWaveletTransform()|
% for more information.
% # Using the filtered image |imgAT|, find all regional maxima in the 3D image.
% Also removes all regional maxima outside the segmented region.
% # Sends regional maxima to the auto thresholding method |imregmaxThresh()| to get
% a value for threshold
% # Spot fitting is run on regional maxima with intensities greater than the
% threshold value. Any adjustment to the threshold, either on the command line or by
% a function like |ThresholdGUI.m|, checks for whether additional spots need to be
% fit. In the |p.run()| method, fired off by |processimageobjects2.m|, we fit twice
% as many spots as the what is suggested by the automatically determined threshold 
% value. This CPU time expense in the batch processing step should allow for quick 
% threshold adjustments in subsequent calls to |p.set.threshold()| from the user via
% the command line, |ThresholdGUI()|, or any other script.

%% Handling new candidate spots after adjusting threshold 
% When the user adjusts the threshold value (such as in |ThresholdGUI|), the 
% threshold setting function 

%% Filter parameters you can set in |proc.filterParams (struct)|
% * s.sigma - (0.5) width of the gaussian to use in |aTrousWaveletTransform()|
% * s.numLevels - (3) number of levels to use in |aTrousWaveletTransform()|

%% Auto threshold parameters you can set in |proc.thresholdParams (struct)|
% * s.brightSpotFlag - (false) make auto thresholder better at transcription sites

%% Methods
% * getSpotCoordinates
% * getNumSpots
% * getImage
% * plotData
% * plotImage

%% Author
% Marshall J. Levesque 2013

classdef aTrousGaussFits < imageProcessors.Processor

    properties
        zMerge   % unscaled, max-merge image, reconstructed with detail bands only
        threshold = -Inf % (double) intensity to threshold regional maxima
        filterParams       % (struct)
        thresholdParams    % (struct) 
        sigmaFilter = [0.6 1.6];  % remove spots with sigma outside here
    end
    
    properties (SetAccess = private)
        srcImgPath       % (str) path to the original image we find spots in
        imageSize        % ([double]) output from |size(img)|
        segmentationRect % (int [1 x 4]) [ top-left-corner-I  -J  Height  Width ]
        regionalMaxValues % ([1xn]) intensities of regional maxima, sorted ascending
        regionalMaxIndices % ([1xn]) 1D positional indices of regional maxima
        spotFits           % (struct) output from |fitSpotPositionsAmps.m|
    end

    methods

        % CONSTRUCTOR METHOD
        function p = aTrousGaussFits(varargin)
            ip = inputParser;
            filterParams.sigma = 0.5; filterParams.numLevels = 3;
            thresholdParams.brightSpotFlag = false;
            ip.addOptional('filterParams',filterParams,@isstruct);
            ip.addOptional('thresholdParams',thresholdParams,@isstruct);
            ip.parse(varargin{:});

            p.description = sprintf(...
                            ['1) aTrous wavelet decomposition\n',...
                             '2) Reconstruct image with detail bands only\n',...
                             '3) Find all regional maxima\n',...
                             '4) Auto threshold on intensity\n'...
                             '5) Fit spots with intensity < threshold\n'...
                             '6) Fits additional spots when threshold adjusted']);

            p.filterParams = ip.Results.filterParams;
            p.thresholdParams = ip.Results.thresholdParams;
        end
        
        function p = run(p,img,varargin)
        % results are in the form of the modified |imageProcessors.Processor|,
        % usually stored in |image_object.channels.(myRNAchannel).processor|
            if nargin ~= 5
                msg = 'Must provide input:\n';
                msg = [msg '\trun(imgStackCropped,croppedImgObjMask,'];
                msg = [msg 'srcImgPath,segmentationRect)\n'];
                fprintf(1,msg);
            else

                if ndims(img) == 3
                    img = img(:,:,1:end);
                end
                p.imageSize = size(img);

                % validate input arguments, save some for later use
                imgObjMask = varargin{1};
                if ~islogical(imgObjMask)
                    error('Image object segmentation mask must be binary image');
                end

                p.srcImgPath = varargin{2};
                if ~ischar(p.srcImgPath) || ~exist(p.srcImgPath,'file')
                    error('Source image path must be a character array');
                end;

                p.segmentationRect = varargin{3}; 
                if ~all(size(p.segmentationRect) == [1 4])
                    msg = 'Segmentation rectangle must be provided as [1x4].\n';
                    msg = [msg '[ top-left-corner-I  J  Height  Width ]'];
                    error(msg);
                end

                % filter the image
                imgAT = aTrousFilter(p,img);

                % find regional maxima
                bw = imregionalmax(imgAT);
        
                % blank out any region of the image outside the segmentation mask
                if ndims(img) == 3  % 3D input image
                    imgObjMask = repmat(imgObjMask,[1 1 size(img,3)]);
                end
                bw = bw & imgObjMask;
                p.regionalMaxValues = imgAT(bw);
                p.regionalMaxIndices = find(bw);
            
                % sort regional maxima in ascending order, store w/ position indices
                [p.regionalMaxValues,I] = sort(p.regionalMaxValues,'ascend');
                p.regionalMaxIndices = p.regionalMaxIndices(I);

                % auto threshold, save to p
                p.threshold = imregmaxThresh(p.regionalMaxValues,...
                                'brightSpotFlag',p.thresholdParams.brightSpotFlag);
                if p.threshold == -Inf  % no threshold
                    p.threshold = max(p.regionalMaxValues)+1; % beyond max, no spots
                end
                p.zMerge = max(imgAT,[],3);

                % fit twice as many spots as the auto-threshold suggests so small
                % adjustments to lower the threshold don't require a pause
                aboveThreshold = p.regionalMaxValues > p.threshold;
                nCands = sum(aboveThreshold) * 2;
                if nCands < 1
                    nCands = 10;
                end
                candInds = p.regionalMaxIndices(end-nCands+1:end);
                p.spotFits = fitSpots(p,img,imgAT,candInds);
            end
        end

        function imgAT = aTrousFilter(p,img)
            % keep detail bands, remove approximation band
            [aTrous,Aj] = aTrousWaveletTransform(img,...
                                'numLevels',p.filterParams.numLevels,...
                                'sigma',p.filterParams.sigma);

            % sum the detail bands to get a filtered image
            if ndims(img) == 3  % 3D input image
                imgAT = sum(aTrous,4);
            else                % 2D input image
                imgAT = sum(aTrous,3);
            end
            clear aTrous; clear Aj;
        end

        function fitresults = fitSpots(p,img,imgAT,regionalMaxima1D)
            [I,J,K] = ind2sub(p.imageSize,regionalMaxima1D);
            fitresults = fitSpotPositionsAmps(imgAT,img,I,J,K);
        end

        function spotInds = getValidSpotIndices(p)
            if ~isempty(p.regionalMaxValues) && ~isempty(p.threshold)
                spotInds = p.regionalMaxValues>p.threshold;
            else
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                spotInds = [];
            end

            % use only the regional maxima that have been fit
            nFits = numel(p.spotFits.xp);
            spotInds = spotInds(end-nFits+1:end);

            % filter out spots with too small/large of Gaussian sigma
            sigs = p.spotFits.sig';  % convert to row vector
            spotInds = spotInds & sigs > p.sigmaFilter(1) & sigs < p.sigmaFilter(2);
        end
        
    
        function numSpots = getNumSpots(p)
            spotInds = getValidSpotIndices(p);
            if isempty(spotInds)
                numSpots = [];
            else
                numSpots = sum(spotInds);
            end
        end

        function [I,J,K] = getSpotCoordinates(p)
            spotInds = getValidSpotIndices(p);
            if isempty(spotInds)
                I = []; J = []; K = [];
            else
                % if no regional maxima above threshold, returns empty IJK
                I = p.spotFits.xp(spotInds);
                J = p.spotFits.yp(spotInds);
                K = p.spotFits.zp(spotInds);
            end
        end
        
        function img = getImage(p,maxIntensity)
        % auto contrast or adjust maximum intensity for increasing contrast
        % for the hot pixel case, or decreasing contrast for no spots case
            if nargin ~= 2 
                img = scale(p.zMerge);
            else
                img = p.zMerge;
                minVal = double(min(img(:)));
                maxVal = double(maxIntensity);
                img = scale(img,[minVal maxVal]);
            end
        end

        function [dataH,threshH] = plotData(p,axH)
        % plot log(number of regional maxima) vs threshold & draw threshold line
            if nargin < 2
                fH = figure; axH = axes('Parent',fH);
            end

            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('Must provide an axes handle for plotting');
            elseif isempty(p.regionalMaxValues)
                error('Procesor has not been run yet');
            end
            numMx = numel(p.regionalMaxValues):-1:1;
            mxs = p.regionalMaxValues;
            dataH = plot(mxs,log(numMx),'b','Parent',axH);
            set(axH,'XLim',[mxs(1) mxs(end)*1.05]);  % give room for zero spot threshold
            hold(axH,'on');
            threshH = plot([p.threshold p.threshold],[0 log(numMx(1))],'g','Parent',axH);
            hold(axH,'off');
        end

        function [imgH,spotsH] = plotImage(p,axH)
        % plot the spots on the zMerge image
            if nargin < 2
                fH = figure; axH = axes('Parent',fH);
            end
            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('Must provide an axes handle for plotting');
            elseif isempty(p.getImage)
                error('Procesor has not been run yet');
            end
            imgH = imshow(p.getImage,'Parent',axH);
            [I,J,K] = p.getSpotCoordinates;
            if isempty(I)  % no spots
                spotsH = [];
            else
                hold(axH,'on');
                spotsH = plot(axH,J,I,'go','MarkerSize',14,'Parent',axH);
                hold(axH,'off');
            end
        end

        function TF = isProcessed(p)
            TF = ~isempty(p.getNumSpots);   % EMPTY means has not been processed
        end

        %-------------------
        % GET / SET METHODS
        %-------------------
        function p = set.threshold(p,intensityValue)
            % Basic purpose is to set a value for the threshold property. More
            % advanced purpose is to figure out whether we need to perform more spot
            % fitting and only perform fitting for those additional spots to avoid
            % redundant work on the CPU. 

            % *NOTES ON REGIONAL MAXIMA & SPOT FITS INDEXING * 
            % Spots are sorted by their original regional max intensity values in 
            % ascending order (ie [low med high-values]). The |p.spotFits| struct()
            % has arrays in each field and their indexing maps to the tail end of the
            % p.regionalMaxIndices/regionalMaxValues arrays. So for the possibly
            % thousands of regional maxima, only the last 100 or so (with intensity
            % values above threshold) will have spot fitting performed.

            if isempty(intensityValue)
                % Threshold cannot be empty, set it to -Inf;
                p.threshold = -Inf;
                return;
            end

            % threshold increased, no need to fit more spots. Set and return
            if intensityValue >= p.threshold 
                p.threshold = intensityValue;
                return;
            end
            
            % if threshold is less than lowest intensity value of fit candiates,
            % perform the spot fitting on the additional regional maxima
            candInds = p.regionalMaxValues > intensityValue;
            nCands = sum(candInds);
            if nCands > 1e4
                fprintf(1,'NOTICE: Aborting setting threshold, >10K spots to fit\n');
                return;
            end
            nFits = numel(p.spotFits.sig);
            if nCands > nFits % do we have more candidates than fits?
                % Load image and fit more spots at regional maxima below threshold.
                % The original image must be available and we crop it 'manually'
                % since we don't have access to |image_object.channelStk()| 
                if ~exist(p.srcImgPath,'file')
                    msg = ['Fitting spots, source image not found: ' p.srcImgPath];
                    error(msg);
                end
                % read the image from disk
                img = readmm(p.srcImgPath);
                img = img.imagedata;
                
                % crop image using segmented image_object bounding box coordinates 
                % this code comes from |image_object.channelStk()|
                b = p.segmentationRect; %[ top-left-corner-I  -J  Height  Width ]
                imgXInds = [b(1):b(1)+b(3)];
                imgYInds = [b(2):b(2)+b(4)];
                img = img(imgYInds,imgXInds,:);

                % filter using aTrous
                imgAT = aTrousFilter(p,img);

                % get the 1D indices of the the additional regional max candidates 
                candInds(end-nFits+1:end) = false; % blank out previous spots
                
                % Perform fitting and append to |p.spotFits| struct()
                fitresults = fitSpots(p,img,imgAT,p.regionalMaxIndices(candInds));
                for f = fieldnames(fitresults)'  % for each field in the struct()
                    f = cell2mat(f);
                    if isfield(p.spotFits,f)
                        p.spotFits.(f) = [fitresults.(f) p.spotFits.(f)];
                    end
                end
            end
            p.threshold = intensityValue;
        end

    end
end
