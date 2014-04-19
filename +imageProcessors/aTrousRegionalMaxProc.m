%% aTrousRegionalMaxProc
% Filters out low frequency details, identifys regional maxima, autothresholds data, 
% provides spot counts and IJK spot coordinates

%% Description
% This processor has 3 main tasks in the |run()| method:
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
% Marshall J. Levesque 2012

classdef aTrousRegionalMaxProc < imageProcessors.Processor

    properties
        zMerge   % unscaled, max-merge image, reconstructed with detail bands only
        threshold
        filterParams
        thresholdParams
        hasClearThreshold = 'NA'; % other allowed values are 'yes', 'no'
    end
    
    properties (SetAccess = private)
        imageSize
        regionalMaxValues
        regionalMaxIndices
    end

    methods

        % CONSTRUCTOR METHOD
        function p = aTrousRegionalMaxProc(varargin)
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
                             '4) Auto threshold on intensity']);

            p.filterParams = ip.Results.filterParams;
            p.thresholdParams = ip.Results.thresholdParams;
        end
        
        
        function p = run(p,img,varargin)
        % results are in the form of the modified image_objects, with processed
        % parameters stored in the Processor property fields
            if nargin ~= 3
                fprintf(1,'Must provide input:\n');
                fprintf(1,'\trun(imgStackCropped,imgObjMask)\n');
            else

                if ndims(img) == 3
                    img = img(:,:,1:end);
                end

                p.imageSize = size(img);
                imgObjMask = varargin{1};

                % aTrous filter. keep detail bands, remove approximation band
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

                % find regional maxima in segmented image, save to |p|
                bw = imregionalmax(imgAT);

                % blank out any region of the image outside the segmentation mask
                if ndims(img) == 3  % 3D input image
                    imgObjMask = repmat(imgObjMask,[1 1 size(img,3)]);
                end
                bw = bw & imgObjMask;
                p.regionalMaxValues = imgAT(bw);
                p.regionalMaxIndices = find(bw);
            
                % sort in ascending order
                [p.regionalMaxValues,I] = sort(p.regionalMaxValues,'ascend');
                p.regionalMaxIndices = p.regionalMaxIndices(I);

                % auto threshold, save to p
                p.threshold = imregmaxThresh(p.regionalMaxValues,...
                                'brightSpotFlag',p.thresholdParams.brightSpotFlag);
                if isempty(p.threshold)
                    p.threshold = max(p.regionalMaxValues)+1; % beyond max, no spots
                end
                p.zMerge = max(imgAT,[],3);
            end
        end
    
        function numSpots = getNumSpots(p)
            if ~isempty(p.regionalMaxValues) && ~isempty(p.threshold)
                numSpots = sum(p.regionalMaxValues>p.threshold);
            else
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                numSpots = [];
            end
        end

        
        
        function [I,J,K] = getSpotCoordinates(p)
            if ~isempty(p.regionalMaxValues) && ~isempty(p.threshold)
                spotInds = p.regionalMaxValues>p.threshold;
                if isempty(spotInds)  % threshold results in no spots
                    I = []; J = []; K = [];
                else
                    [I,J,K] = ind2sub(p.imageSize,p.regionalMaxIndices(spotInds));
                end
            else
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                I = []; J = []; K = [];
            end
        end
        
        function [img, minAndMaxInUnscaledImg] = getImage(p,maxIntensity)
        % auto contrast or adjust maximum intensity for increasing contrast
        % for the hot pixel case, or decreasing contrast for no spots case
            img = p.zMerge;
            minVal = double(min(img(:)));
            maxVal = double(max(img(:)));
            minAndMaxInUnscaledImg = [minVal, maxVal];
            
            if nargin ~= 2 
                img = scale(img);
            else
                maxVal = double(maxIntensity);
                img = scale(img, [minVal maxVal]);
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
        
        function p = set.hasClearThreshold(p, val)
            if val == true
                p.hasClearThreshold = 'yes';
            elseif val == false
                p.hasClearThreshold = 'no';
            elseif isempty(val)
                p.hasClearThreshold = 'NA';
            else
                p.hasClearThreshold = val;
            end
        end
        
    end
end
