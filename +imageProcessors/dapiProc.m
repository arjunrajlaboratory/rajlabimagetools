classdef dapiProc < imageProcessors.Processor

    properties
        zMerge
        mask
    end

    methods

        % CONSTRUCTOR METHOD
        function p = dapiProc(description)
            if nargin~=0
                p.description = description;
            else
                p.description = 'Create z-projection and binary mask for nucleus';
            end
        end

        function p = run(p,imgStackCropped,varargin)
            if nargin ~= 3
                fprintf(1,'Must provide input:\n');
                fprintf(1,'\trun(imgStkCropped,imgObjMask)\n');
            else
                % max merge z-projection
                p.zMerge= max(imgStackCropped,[],3);

                imgObjMask = varargin{1};

                % Previous DAPI masking failed in cases where there were bright
                % chromatin spots and created a mask around though spots instead of
                % a nucleus mask. This method utilizes the aTrousWaveletTransform 
                % in order to identify the dapi mask as a large detail band, using a
                % much larger sigma and more detail levels that when finding spots.
                % Author: Andrew Biaesch <biaescha@gmail.com> June 2013
                
                % Get an initial feel for the area that the dapi is in
                imgscaled = scale(p.zMerge);
                p.mask = imgscaled>graythresh(imgscaled);
                subtr_area = sum(p.mask(:));
                
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
                    p.mask = imdilate(p.mask,strel('line',10,0));
                    p.mask = imdilate(p.mask,strel('line',10,90));
                end
                
                p.mask = p.mask & aTrous_mask;
                p.mask = p.mask & imgObjMask;
                
                % get rid of stuff on segmentation border, check if anything left
                masktmp = imclearborder(p.mask | ~imgObjMask); 
                masktmp = bwareaopen(masktmp,20); % must be bigger than 20 pixels
                if any(masktmp(:))
                    p.mask = masktmp;
                end

                if ~any(p.mask(:))
                    p.mask = [];
                    fprintf(1,'NOTICE: Could not create a mask\n');
                end
            end
        end

        % NOTICE: there are no getNumSpots or getSpotCoordinates functions
        % defined for this Processor

        function img = getImage(p)
            if isempty(p.zMerge)
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                img = [];
            else
                img = scale(p.zMerge);
            end
        end

        function [imgH,perimH] = plotImage(p,axH)
        % plot the mask border on the zMerge image
            if nargin < 2
                fH = figure; axH = axes('Parent',fH);
            end

            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('Must provide an axes handle for plotting');
            elseif isempty(p.getImage)
                error('Procesor has not been run yet');
            end
            imgH = imshow(p.getImage,'Parent',axH);
            if isempty(p.mask)  % no spots
                perimH = [];
                disp 'test'
            else
                perimMask = bwperim(p.mask);
                hold(axH,'on');
                [I,J] = ind2sub(size(p.mask),find(perimMask(:)));
                perimH = plot(axH,J,I,'r.');  % dots around the DAPI
                hold(axH,'off');
            end
        end

        function TF = isProcessed(p)
            TF = ~isempty(p.zMerge);   % EMPTY means has not been processed
        end
    end
end
