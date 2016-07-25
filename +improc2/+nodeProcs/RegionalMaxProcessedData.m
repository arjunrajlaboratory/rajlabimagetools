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
        threshold
        excludedSlices
        regionalMaxValues
        regionalMaxIndices
        imageSize
        zMerge
    end
    
    properties (Access = private)
        storedZMerge
        storedImageSize
        storedThreshold
        storedRegionalMaxValues
        storedRegionalMaxIndices
        storedExcludedSlices = [];
    end
    
    methods
        function zMerge = get.zMerge(pData)
            if isempty(pData.excludedSlices)
                zMerge = pData.storedZMerge;
            else
                % temporary
%                 channel = thresholdGUIControls.rnaChannelSwitch.getChannelName;
                
                % find raw cropped image stack
                channelStkContainer = pData.dependencyClassNames{1};
                disp(channelStkContainer)
                moreinfo(channelStkContainer)
                disp(channelStkContainer.channelName)
                img = channelStkContainer.croppedImage;
                
                % filter image
                filteredImg = pData.imageFilterFunc(img, pData.filterParams);
                
                % get range without excluded slices
                nPlanes = size(filteredImg, 3);
                exSlices = pData.excludedSlices;
                
                filteredImg2 = filteredImg(:,:,~ismember(1:nPlanes, exSlices));
                
                % generate zMerge with excluded slices
                zMerge = max(filteredImg2,[],3);
            end
        end
        function pData = set.zMerge(pData, zMerge)
            pData.storedZMerge = zMerge;
        end
        function sz = get.imageSize(pData)
            sz = pData.storedImageSize;
        end
        function pData = set.imageSize(pData, sz)
            pData.storedImageSize = sz;
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
        function pData = set.regionalMaxValues(pData, values)
            assert(isempty(pData.storedExcludedSlices), 'have excluded slices. cannot set')
            pData.storedRegionalMaxValues = values;
        end
        function indices = get.regionalMaxIndices(pData)
            indices = pData.storedRegionalMaxIndices;
            indices = indices(findMaximaInIncludedSlices(pData));
        end
        function pData = set.regionalMaxIndices(pData, indices)
            assert(isempty(pData.storedExcludedSlices), 'have excluded slices. cannot set')
            pData.storedRegionalMaxIndices = indices;
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
            
            pData.storedZMerge = max(filteredImg,[],3);
            pData.storedRegionalMaxValues = regionalMaxValues;
            pData.storedRegionalMaxIndices = regionalMaxIndices;
            pData.storedThreshold = threshold;
            pDataAfterProcessing = pData;
        end
        
        function numSpots = getNumSpots(p)
            numSpots = sum(p.regionalMaxValues>p.threshold);
        end
        
                
        function thresholdSensitivity = getThresholdSensitivity(p)
            regionalMaxValues = double(p.regionalMaxValues);  % Assumes this is sorted from lowest to highest
            threshold = p.threshold;
            
            if threshold >= max(regionalMaxValues) % i.e., threshold results in no spots
                thresholdSensitivity = 0;
            else
                % Note: if regionalMaxValues has any duplicate values, then
                % interpolation won't work. So we have to add something to
                % spread out these values a bit.
                
                diffRegionalMaxValues = diff(regionalMaxValues);
                duplicateIndices = find(diffRegionalMaxValues==0);
                minDiff = min(diffRegionalMaxValues(diffRegionalMaxValues ~= 0));
                regionalMaxValues(duplicateIndices) = regionalMaxValues(duplicateIndices) - minDiff/100*(1-duplicateIndices/length(regionalMaxValues)); % separates these duplicate values
                                
                minRegionalMaxValue = min(regionalMaxValues);
                %maxRegionalMaxValue = max(regionalMaxValues); % instead, included more complex logic here to get rid of txn site outliers
                regionalMaxValuesAboveThreshold = regionalMaxValues(regionalMaxValues > threshold);
                numRegionalMaxValuesAboveThreshold = numel(regionalMaxValuesAboveThreshold);
                % Logic is: if more than 5 spots, get rid of at least 2 or
                % 10% of total spots, whichever is higher.
                if numRegionalMaxValuesAboveThreshold > 5
                    mx = max([2,round(0.10*numRegionalMaxValuesAboveThreshold)]);
                    maxRegionalMaxValue = max(regionalMaxValues(1:end-mx));
                else
                    maxRegionalMaxValue = max(regionalMaxValues);
                end
                                
                y = numel(regionalMaxValues):-1:1;
                x = linspace(minRegionalMaxValue,maxRegionalMaxValue,200);
                
                regionalMaxPlateauPlot = interp1(regionalMaxValues,y,x);
                
                derivativeSmoothedPlateauPlot = diff(smooth(log(regionalMaxPlateauPlot)));
                
                sensitivity = interp1(x(1:end-1) + (x(2)-x(1))/2, derivativeSmoothedPlateauPlot, threshold);
                
                thresholdSensitivity = -sensitivity;
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
        
        function [img, minAndMaxInUnscaledImg] = getImage(p,maxIntensity)
            % auto contrast or adjust maximum intensity for increasing contrast
            % for the hot pixel case, or decreasing contrast for no spots case
%             img = p.storedZMerge;
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

