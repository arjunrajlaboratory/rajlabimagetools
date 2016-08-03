classdef SparseTissueRegionalMaxProcessedData < improc2.nodeProcs.RegionalMaxProcessedData
    % An object that applies an aTrousFilter prior regional-maxima based spot finding.
    
    methods
        function p = SparseTissueRegionalMaxProcessedData(varargin)
            % This is copied from the aTrousFilter, because it sets the
            % filter parameters the same way.
            p.filterParams = improc2.aTrousFilterParams(struct('sigma',0.5,'numLevels',3));
            p.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            ip = inputParser;
            ip.addOptional('filterParams', struct());
            ip.parse(varargin{:});
            
            p.filterParams = p.filterParams.replaceParams( ip.Results.filterParams );
        end
        
        function pDataAfterProcessing = run(pData, channelStkContainer)
            
            img = channelStkContainer.croppedImage;
            imgObjMask = channelStkContainer.croppedMask;
            
            pData.storedImageSize = size(img);
            filteredImg = pData.imageFilterFunc(img, pData.filterParams);
            
            medianStack = medianfilter(filteredImg);
            medianStack = imgaussfilt3(medianStack,1);
            
            bw = imregionalmax(medianStack);
            
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
    end
end

