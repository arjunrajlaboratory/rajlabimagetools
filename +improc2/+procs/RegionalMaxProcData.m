classdef RegionalMaxProcData < improc2.procs.ProcessorData & ...
        improc2.SpotFindingInterface & improc2.ImageDisplayer
    
    
    
    properties (SetAccess = private)
        autoThresholdParams = struct('brightSpotFlag', false);
    end
    
    properties (SetAccess = protected)
        filterParams = improc2.ParamList();
        imageFilterFunc = @(x, filterParams) x;
    end
    
    properties (Dependent = true)
        threshold % settable
        hasClearThreshold  % settable
        excludedSlices % settable
        regionalMaxValues
        regionalMaxIndices
        imageSize
    end
    
    properties (SetAccess = private)
        zMerge
    end
    
    properties (Access = private)
        storedImageSize
        storedThreshold
        storedRegionalMaxValues
        storedRegionalMaxIndices
        storedHasClearThresholdStatus = improc2.TypeCheckedYesNoOrNA('NA');
        storedExcludedSlices = [];
    end
    
    methods
        function sz = get.imageSize(pData)
            sz = pData.storedImageSize;
        end
        function slices = get.excludedSlices(pData)
            slices = pData.storedExcludedSlices;
        end
        function pData = set.excludedSlices(pData, slices)
            slices = slices(:);
            assert(isnumeric(slices) && all(mod(slices, 1) == 0) && all(slices > 0) &&...
                all(slices <= pData.imageSize(3)), 'improc2:BadArguments', ...
                'Slices must be an array of integers between 1 and %d',...
                pData.imageSize(3))
            pData.storedExcludedSlices = slices;
        end
        function values = get.regionalMaxValues(pData)
            values = pData.storedRegionalMaxValues;
            values = values(findMaximaInIncludedSlices(pData));
        end
        function indices = get.regionalMaxIndices(pData)
            indices = pData.storedRegionalMaxIndices;
            indices = indices(findMaximaInIncludedSlices(pData));
        end
        function yesNoOrNA = get.hasClearThreshold(pData)
            yesNoOrNA = pData.storedHasClearThresholdStatus.value;
        end
        function pData = set.hasClearThreshold(pData, yesNoOrNA)
            pData.storedHasClearThresholdStatus.value = yesNoOrNA;
        end
        function threshold = get.threshold(pData)
            threshold = pData.storedThreshold;
        end
        function pData = set.threshold(pData, threshold)
            pData.dataHasChanged = true;
            pData.storedThreshold = threshold;
        end
    end
    
    methods (Access = protected)
        
        function pDataAfterProcessing = runProcessor(pData, varargin)
            
            [img, imgObjMask] = improc2.getArgsForClassicProcessor(varargin{:});
            pData.storedImageSize = size(img);
            filteredImg = pData.imageFilterFunc(img, pData.filterParams);
            
            bw = imregionalmax(filteredImg);
            
            % blank out any region of the image outside the segmentation mask
            if ndims(img) == 3  % 3D input image
                imgObjMask = repmat(imgObjMask,[1 1 size(img,3)]);
            end
            bw = bw & imgObjMask;
            regionalMaxValues = filteredImg(bw);
            regionalMaxIndices = find(bw);
            
            [regionalMaxValues,I] = sort(regionalMaxValues,'ascend');
            regionalMaxIndices = regionalMaxIndices(I);
            
            % auto threshold, save to p
            try
                threshold = imregmaxThresh(regionalMaxValues,...
                    'brightSpotFlag',pData.autoThresholdParams.brightSpotFlag);
            catch % Convert input to double precision if it failed
                threshold = imregmaxThresh(...
                    double(regionalMaxValues) , 'brightSpotFlag', ...
                    pData.autoThresholdParams.brightSpotFlag);
            end
            if isempty(threshold)
                threshold = max(regionalMaxValues)+1; % beyond max, no spots
            end
            
            pData.zMerge = max(filteredImg,[],3);
            pData.storedRegionalMaxValues = regionalMaxValues;
            pData.storedRegionalMaxIndices = regionalMaxIndices;
            pData.storedThreshold = threshold;
            pDataAfterProcessing = pData;
        end
    end
    
    methods
        function p = RegionalMaxProcData(varargin)
            p.description = sprintf(...
                ['1) Find all regional maxima\n',...
                '2) Auto threshold on intensity']);
            
            ip = inputParser;
            ip.addOptional('autoThresholdParams', p.autoThresholdParams, @isstruct);
            ip.parse(varargin{:});
            
            p.autoThresholdParams = ip.Results.autoThresholdParams;
        end
        
        function numSpots = getNumSpots(p)
            if p.isProcessed
                numSpots = sum(p.regionalMaxValues>p.threshold);
            else
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                numSpots = [];
            end
        end
        
        function [I,J,K] = getSpotCoordinates(p)
            spotInds = p.regionalMaxValues > p.threshold;
            if isempty(spotInds)  % threshold results in no spots
                I = []; J = []; K = [];
            else
                [I,J,K] = ind2sub(p.imageSize,p.regionalMaxIndices(spotInds));
            end
        end
        
        function [I, J, K] = getSpotCoordinatesIncludingExcludedSlices(p)
            spotInds = p.storedRegionalMaxValues > p.threshold;
            if isempty(spotInds)  % threshold results in no spots
                I = []; J = []; K = [];
            else
                [I,J,K] = ind2sub(p.imageSize,p.storedRegionalMaxIndices(spotInds));
            end
        end
        
        function [imgH, spotsH, axH] = plotImage(p, varargin)
            [imgH, axH] = p.plotImage@improc2.ImageDisplayer(varargin{:});
            
            [I,J,K] = p.getSpotCoordinates();
            if isempty(I)  % no spots
                spotsH = [];
            else
                hold(axH,'on');
                spotsH = plot(axH,J,I,'go','MarkerSize',14,'Parent',axH);
                hold(axH,'off');
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
        
        function [dataH, threshH] = plotData(pData, axH)
            if nargin < 2
                fH = figure; axH = axes('Parent',fH);
            end
            
            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('Must provide an axes handle for plotting');
            elseif isempty(pData.regionalMaxValues)
                error('Procesor has not been run yet');
            end
            numMx = numel(pData.regionalMaxValues):-1:1;
            mxs = pData.regionalMaxValues;
            dataH = plot(mxs,log(numMx),'b','Parent',axH);
            set(axH,'XLim',[mxs(1) mxs(end)*1.05]);  % give room for zero spot threshold
            hold(axH,'on');
            threshH = plot([pData.threshold pData.threshold],[0 log(numMx(1))],'g','Parent',axH);
            hold(axH,'off');
        end
    end
    
    methods (Access = private)
        function maximaNotExcluded = findMaximaInIncludedSlices(p)
            [~, ~, K] = ind2sub(p.imageSize, p.storedRegionalMaxIndices);
            maximaNotExcluded = ~ ismember(K, p.storedExcludedSlices);
        end
    end
end

