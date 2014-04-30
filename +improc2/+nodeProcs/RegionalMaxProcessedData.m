classdef RegionalMaxProcessedData < improc2.interfaces.ProcessedData & ...
        improc2.interfaces.SpotsProvider
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'imageSource'};
    end
    
    properties (SetAccess = private)
        autoThresholdParams = struct('brightSpotFlag', false);
    end
    
    properties (SetAccess = protected)
        filterParams = improc2.ParamList();
        imageFilterFunc = @(x, filterParams) x;
    end
    
    properties (Dependent = true)
        threshold % settable
        excludedSlices % settable
        regionalMaxValues
        regionalMaxIndices
        imageSize
    end
    
    properties (Access = private)
        zMerge
        storedImageSize
        storedThreshold
        storedRegionalMaxValues
        storedRegionalMaxIndices
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
        function threshold = get.threshold(pData)
            threshold = pData.storedThreshold;
        end
        function pData = set.threshold(pData, threshold)
            pData.storedThreshold = threshold;
        end
    end
    
    
    methods
        function p = RegionalMaxProcessedData()
        end
        
        function pDataAfterProcessing = run(pData, channelStkContainer)
            
            img = channelStkContainer.croppedImage;
            imgObjMask = channelStkContainer.croppedMask;
            
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
        
        function numSpots = getNumSpots(p)
            numSpots = sum(p.regionalMaxValues>p.threshold);
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
    end
    
    methods (Access = private)
        function maximaNotExcluded = findMaximaInIncludedSlices(p)
            [~, ~, K] = ind2sub(p.imageSize, p.storedRegionalMaxIndices);
            maximaNotExcluded = ~ ismember(K, p.storedExcludedSlices);
        end
    end
end

