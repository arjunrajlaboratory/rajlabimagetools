classdef RegionalMaxProcData < improc2.procs.ProcessorData & ...
        improc2.SpotFindingInterface & improc2.ImageDisplayer
    
    properties
        threshold % has its own setter.
        hasClearThreshold = true;
    end
    
    properties (SetAccess = private)
        autoThresholdParams = struct('brightSpotFlag', false); % used for automatic thresholding
        regionalMaxValuesAllSlices
        regionalMaxIndicesAllSlices
        slicesToIgnore
    end
    
    properties (Dependent = true)
        regionalMaxValues
        regionalMaxIndices
    end
    
    properties (SetAccess = protected)
        filterParams = improc2.ParamList();
        imageFilterFunc = @(x, filterParams) x;
    end
    
    properties (Access = private)
        zMerge;
        imageSize
    end
    
    methods (Access = protected)
        
        function pDataAfterProcessing = runProcessor(pData, varargin)
            
            [img, imgObjMask] = improc2.getArgsForClassicProcessor(varargin{:});
            pData.imageSize = size(img);
            filteredImg = pData.imageFilterFunc(img, pData.filterParams);
            
            bw = imregionalmax(filteredImg);
            
            % blank out any region of the image outside the segmentation mask
            if ndims(img) == 3  % 3D input image
                imgObjMask = repmat(imgObjMask,[1 1 size(img,3)]);
            end
            bw = bw & imgObjMask;
            pData.regionalMaxValuesAllSlices = filteredImg(bw);
            pData.regionalMaxIndicesAllSlices = find(bw);
            
            [pData.regionalMaxValuesAllSlices,I] = sort(pData.regionalMaxValuesAllSlices,'ascend');
            pData.regionalMaxIndicesAllSlices = pData.regionalMaxIndicesAllSlices(I);
            
            % auto threshold, save to p
            try
                pData.threshold = imregmaxThresh(pData.regionalMaxValuesAllSlices,...
                    'brightSpotFlag',pData.autoThresholdParams.brightSpotFlag);
            catch % Convert input to double precision if it failed
                pData.threshold = imregmaxThresh(...
                    double(pData.regionalMaxValuesAllSlices) , 'brightSpotFlag', ...
                    pData.autoThresholdParams.brightSpotFlag);
            end
            if isempty(pData.threshold)
                pData.threshold = max(pData.regionalMaxValuesAllSlices) + 1; % beyond max, no spots
            end
            pData.zMerge = max(filteredImg,[],3);
            
            pDataAfterProcessing = pData;
        end
    end
    
    methods
        function vals = get.regionalMaxValues(pData)
            vals = p.selectNotInIgornedSlices(pData.regionalMaxValuesAllSlices);
        end
        function idx = get.regionalMaxIndices(pData)
            idx = p.selectNotInIgnoredSlices(pData.regionalMaxIndices); 
        end
    end
    
    methods (Access = private)
        function idx = findRegionalMaximaInIgnoredSlices(pData)
            pData.
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
            if p.isProcessed
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
        
        function p = set.threshold(p, threshold)
            p.dataHasChanged = true;
            p.threshold = threshold;
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
        
        function p = updateProcByDataPlotXYPOS(p, position)
            p = p.plotStrategy.updateProcByDataPlotXYPOS(p, position);
        end
        
        function p = setnotdone(p)
            p = p.setNotDoneProcessing();
        end
        
    end
    
    
    
end

