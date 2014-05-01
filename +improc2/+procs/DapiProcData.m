classdef DapiProcData < improc2.procs.ProcessorData & improc2.ImageDisplayer
    % An object that employs a specific algorithm to determine a nuclear mask based on a nuclear stain. Also stores a max merge for display.
    
    properties (Dependent = true)
        mask
    end
    
    properties (SetAccess = private)
        zMerge
    end
    
    properties (Access = private)
        storedMask
    end
    
    methods
        function mask = get.mask(pData)
            mask = pData.storedMask;
        end
    end
    
    methods (Access = protected)
        
        function pDataAfterProcessing = runProcessor(pData, varargin)
            
            [imgStackCropped, imgObjMask] = improc2.getArgsForClassicProcessor(varargin{:});
            % max merge z-projection
            pData.zMerge= max(imgStackCropped,[],3);
            
            % Previous DAPI masking failed in cases where there were bright
            % chromatin spots and created a mask around though spots instead of
            % a nucleus mask. This method utilizes the aTrousWaveletTransform
            % in order to identify the dapi mask as a large detail band, using a
            % much larger sigma and more detail levels that when finding spots.
            % Author: Andrew Biaesch <biaescha@gmail.com> June 2013
            
            % Get an initial feel for the area that the dapi is in
            imgscaled = scale(pData.zMerge);
            mask = imgscaled>graythresh(imgscaled);
            subtr_area = sum(mask(:));
            
            numLevels = 5;
            sigma = 2;
            [aTrous, Aj] = aTrousWaveletTransform(imgStackCropped,...
                numLevels,...
                sigma);
            aTrous_merge = max(aTrous(:,:,:,numLevels), [], 3);
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
    end
    
    
    methods
        
        function pData = DapiProcData()
            pData@improc2.procs.ProcessorData('Finds nuclear mask based on nuclear stain')
        end
        
        function img = getImage(pData, varargin)
            img = scale(pData.zMerge);
        end
        
        function [imgH, axH, perimH] = plotImage(pData,varargin)
            [imgH, axH] = pData.plotImage@improc2.ImageDisplayer(varargin{:});
            
            if isempty(pData.mask)
                perimH = [];
                disp 'test'
            else
                perimMask = bwperim(pData.mask);
                hold(axH,'on');
                [I,J] = ind2sub(size(pData.mask),find(perimMask(:)));
                perimH = plot(axH,J,I,'r.');
                hold(axH,'off');
            end
        end
        
    end
    
end

