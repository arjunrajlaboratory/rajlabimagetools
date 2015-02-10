classdef DapiProcessedData < improc2.interfaces.ProcessedData & ...
        improc2.interfaces.MaskContainer
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'imageSource'};
    end
    
    properties (Dependent = true)
        mask
        zMerge
    end
    
    properties (Access = private)
        storedMask
        storedZMerge
    end
    
    
    methods
        function pData = DapiProcessedData()
        end
        
        function pDataAfterProcessing = run(pData, channelStackContainer)
            
            imgStackCropped = channelStackContainer.croppedImage;
            imgObjMask = channelStackContainer.croppedMask;
            % max merge z-projection
            pData.storedZMerge= max(imgStackCropped,[],3);
            
            % Previous DAPI masking failed in cases where there were bright
            % chromatin spots and created a mask around though spots instead of
            % a nucleus mask. This method utilizes the aTrousWaveletTransform
            % in order to identify the dapi mask as a large detail band, using a
            % much larger sigma and more detail levels that when finding spots.
            % Author: Andrew Biaesch <biaescha@gmail.com> June 2013
            
            % Get an initial feel for the area that the dapi is in
            imgscaled = scale(pData.storedZMerge);
            mask = imgscaled>graythresh(imgscaled);
            subtr_area = sum(mask(:));
            
            numLevels = 5;
            sigma = 2;
            [aTrous, Aj] = aTrousWaveletTransform(imgStackCropped,...
                numLevels,...
                sigma);
            if size(aTrous, 3) == 1
                aTrous_merge = max(aTrous(:,:,:,numLevels), [], 3);
            else
                aTrous_merge = max(aTrous(:,:,:,numLevels), [], 3);
            end
            aTrous_mask = aTrous_merge > graythresh(aTrous_merge);
            aTrous_mask = imfill(aTrous_mask, 'holes');
            aTrous_area = sum(aTrous_mask(:));
            
            % If the areas are similar, prefer to use aTrous; so dilate the
            % subtr image such that it encompases the aTrous. There are some
            % cases in which aTrousWaveletTransform fails, creating a BW image
            % that a large area of the image is white. Use the normal
            % graythresh image in this case
            % Author: Andrew Biaesch <biaescha@gmail.com> June 2013
            
            if (.9 < (aTrous_area/subtr_area) < 1.1)
                mask = imdilate(mask,strel('line',10,0));
                mask = imdilate(mask,strel('line',10,90));
            end
            
            mask = mask & aTrous_mask;
            mask = mask & imgObjMask;
            
            % get rid of stuff on segmentation border, check if anything left
            masktmp = imclearborder(mask | ~imgObjMask);
            masktmp = bwareaopen(masktmp,20); % must be bigger than 20 pixels
            if any(masktmp(:))
                mask = masktmp;
            end
            
            if ~any(mask(:))
                mask = [];
                fprintf(1,'NOTICE: Could not create a mask\n');
            end
            
            pData.storedMask = mask;
            
            pDataAfterProcessing = pData;
        end        
        
        function img = getImage(pData, varargin)
            if ~isempty(pData.storedZMerge)
                img = scale(pData.storedZMerge);
            else
                img = [];
            end
        end
        
        function mask = get.mask(pData)
            mask = pData.storedMask;
        end
        function pData = set.mask(pData, mask)
            pData.storedMask = mask;
        end
        function zMerge = get.zMerge(pData)
            zMerge = pData.storedZMerge;
        end
        function pData = set.zMerge(pData, zMerge)
            pData.storedZMerge = zMerge;
        end
        
    end
    
end

