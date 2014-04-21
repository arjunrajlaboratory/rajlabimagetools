%% generateColorMapFromData
% Generates color maps using just the data files produced by DentistGUI

%% Input:
% The name of the data file
%% Output:
% rnaMaps contains the rna density maps and cellMaps the cell square
% mapping.  rnaMaps and cellMaps are 1xN vectors of cells where each cell
% contains the rgb image

function [rnaMaps, cellMaps] = generateColorMapFromData(dataFileName)

    % Everything below the cutOff is being given the same value to
    % ensure the colormap is being utilized on the top intensity
    % values - This is for the RNA DENSITY MAP ONLY
    cutOffValue = 0.85;
    
    Hs = load(dataFileName);
    
    Hs.row_width = Hs.imageSize(1) * Hs.rows - (Hs.overlap * (Hs.rows - 1));
    Hs.col_width = Hs.imageSize(2) * Hs.cols - (Hs.overlap * (Hs.cols - 1));
    
    chanMapsTemp = [];
    centroidMapsTemp = [];
    chanIndex = 1;
    myColorMap = colormap(jet(255));
    for index = 1:numel(Hs.foundChannels)
        if ~strcmp(cell2mat(Hs.foundChannels(index)),'dapi')
            
            if ~isfield(Hs,'waitbarH') || ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar(0,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
            else
                waitbar(0,Hs.waitbarH,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
            end
            % Determine what the threshold is
            if isfield(Hs,'chanThreshVal')
                Hs.threshold = Hs.chanThreshVal(chanIndex,1);
            else
                Hs.threshold = median(cell2mat(Hs.chanThresh(chanIndex)));
            end
            % original size of the scan
            scanDims = [Hs.row_width Hs.col_width];
            % size of final image - number of "bins" which larger image
            % will have to funnel into
            finalDim = [1000 1000];
            % Create canvas
            resampledS = zeros(finalDim);
            resampledC = zeros([finalDim,3]);
            % scaling factor
            scale = scanDims ./ finalDim;
            % Get the subset of spots and spotmap for which the intensity
            % values are above the threshold
            spots2 = cell2mat(Hs.chanSpots(chanIndex));
            spotMap = cell2mat(Hs.chanSpotMaps(chanIndex));
            
            spotDel = [];
            if ~isempty(Hs.chanDeleted)
                deleted = cell2mat(Hs.chanDeleted(chanIndex));
            else
                deleted = [];
            end
            
            spotDel(1:size(spots2,1),1) = 1;
            spotDel(deleted,1) = 0;
        
            spots = spots2(spots2(:,3) >= Hs.threshold & spotDel(:,1) == 1,1:3);
            spotMap = spotMap(spots2(:,3) >= Hs.threshold & spotDel(:,1) == 1,1);
            % Remove the spots for which spotMap value is -1.  These are
            % the spots that are greater than Hs.maxDist away from nearest
            % cell
            spots(spotMap == -1,:) = [];
            spotMap(spotMap == -1,:) = [];
            
            % lengthSpots and div are used for calculating percent completed
            % for waitbar display
            lengthSpots = size(spots,1);
            div = round(lengthSpots/40);
            if div == 0
                div = 1;
            end
            % For each spot add numSpots to a box whose rows span from
            % ind(1) +/- addWidth and cols span from ind(2) +/- addWidth
            % where ind are row [row,col] of the spot and numSpots is the
            % number of spots attributed to the centroid to which this spot
            % belongs
            for r = 1:size(spots,1)
                if mod(r,div) == 0 || r == lengthSpots
                    if ~ishandle(Hs.waitbarH)
                        Hs.waitbarH = waitbar(r/lengthSpots,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)));
                    else
                        waitbar(r/lengthSpots,Hs.waitbarH,strcat('Generating color map ',int2str(chanIndex),' of ',int2str(numel(Hs.foundChannels) - 1)))
                    end
                end
                ind = spots(r,:);
                addWidth = 100;
                %----------------------------------------------------------
                rowLowO = ind(1) - addWidth;
                if rowLowO < 1
                    rowLowO = 1;
                end
                % Convert to scaled image coordinates
                rowLow = floor((rowLowO - 1) / scale(1)) + 1;
                %----------------------------------------------------------
                rowHighO = ind(1) + addWidth;
                if rowHighO > Hs.row_width
                    rowHighO = Hs.row_width;
                end
                % Convert to scaled image coordinates
                rowHigh = floor((rowHighO - 1) / scale(1)) + 1;
                %----------------------------------------------------------
                colLowO = ind(2) - addWidth;
                if colLowO < 1
                    colLowO = 1;
                end
                % Convert to scaled image coordinates
                colLow = floor((colLowO - 1) / scale(2)) + 1;
                %----------------------------------------------------------
                colHighO = ind(2) + addWidth;
                if colHighO > Hs.col_width
                    colHighO = Hs.col_width;
                end
                % Convert to scaled image coordinates
                colHigh = floor((colHighO - 1) / scale(2)) + 1;
                %----------------------------------------------------------
                %Find the number of spots attributed to the centroid for
                %which this spot is attributed to
                spotAttSubSet = spots(spotMap(:,1) == spotMap(r,1) & spots(:,3) > Hs.threshold,:);
                numSpots = size(spotAttSubSet,1);
                value = numSpots;
                resampledS(rowLow:rowHigh,colLow:colHigh) = resampledS(rowLow:rowHigh,colLow:colHigh) + value;
            end

            if ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar(0,strcat('Mapping intensities'));
            else
                waitbar(0,Hs.waitbarH,strcat('Mapping intensities'));
            end
            %The indices of the zeros in the image
            zeroINDs = (resampledS == 0);
            % lengthCents and div used by waitbar
            lengthCents = size(Hs.centroids,1);
            div = round(lengthCents/40);
            if div == 0
                div = 1;
            end
            centroids = Hs.centroids;
            centroids(Hs.centDeleted,:) = [];
            % centInts will contain the intensity values at the location at
            % each of the centroids
            centInts = [];
            for index = 1:size(centroids,1)
                if mod(index,div) == 0 || index == lengthCents
                    if ~ishandle(Hs.waitbarH)
                        Hs.waitbarH = waitbar(index/lengthCents,strcat('Mapping intensities'));
                    else
                        waitbar(index/lengthCents,Hs.waitbarH,strcat('Mapping intensities'));
                    end
                end
                loc = centroids(index,:);
                % Scale to small image coordinates
                loc(1) = floor((loc(1) - 1) / scale(1) + 1);
                loc(1) = max(loc(1),1);
                loc(2) = floor((loc(2) - 1) / scale(2) + 1);
                loc(2)  = max(loc(2),1);
                centInts = [centInts,resampledS(loc)];
            end
            [vals,INDs] = sort(centInts);
            % The bottom cutOffValue of values (85% if cutOffValue = 0.85) will all have the same color.
            % Everything below the cutOff is being given the same value to
            % ensure the colormap is being utilized on the top intensity
            % values
            cutOff = vals(round(numel(centInts) * cutOffValue));
            resampledS(resampledS < cutOff) = cutOff;
            % Take the log to diminish effects of outliers on colormap
            resampledS = log(resampledS);
            gray = mat2gray(resampledS);
            rgb = ind2rgb(gray2ind(gray,255),jet(255));
            % rgb has three layers.  for the indexes that were previously
            % zero (changed when values below cutOff were set to cutOff),
            % set them to black - deal with each layer individual since
            % coordinates are linear 2D coordinates
            layer1 = rgb(:,:,1);
            layer1(zeroINDs) = 0;
            layer2 = rgb(:,:,2);
            layer2(zeroINDs) = 0;
            layer3 = rgb(:,:,3);
            layer3(zeroINDs) = 0;
            rgb = cat(3,layer1,layer2,layer3);
            chanMapsTemp = [chanMapsTemp,mat2cell(rgb)];
            
            %--------------------------------------------------------------
            % Centroid map generation
            %--------------------------------------------------------------  
            % Create the centroid map for this channel
            tab = tabulate(spotMap(spotMap ~= -1));
            %Second column contains if active
            centroidMap = tab(:,2);
            centroidMap(:,2) = 1;
            centroidMap(Hs.centDeleted,2) = 0;
            padding = [];
            if ~ishandle(Hs.waitbarH)
                Hs.waitbarH = waitbar(index/lengthCents,strcat('Mapping centroids'));
            else
                waitbar(index/lengthCents,Hs.waitbarH,strcat('Mapping centroids'));
            end
            if size(centroidMap,1) < size(Hs.centroids,1)
                padding = zeros(size(Hs.centroids,1) - size(centroidMap,1),2);
                centroidMap = [centroidMap;padding];
            end
            spotMax = max(centroidMap(:,1));
            
            centroidSet = Hs.centroids(:,1:2);
            matSort = [centroidSet,centroidMap];
            [matSort,IND] = sortrows(matSort,3);
            centroidSet = matSort(:,1:2);
            centroidMap = matSort(:,3);
            % Translate old deleted centroid rows to new rows
            centDelTrans = find(ismember(IND,Hs.centDeleted));
            
            
            for index = 1:size(centroidSet,1)
                % Continue only if centroid has not been deleted
                if isempty(find(centDelTrans == index))
                    ind = centroidSet(index,1:2);
                    addWidth = 3;
                    row = floor((ind(1) - 1) / scale(1)) + 1;
                    col = floor((ind(2) - 1) / scale(2)) + 1;
                    
                    rowLow = row - addWidth;
                    if rowLow < 1
                        rowLow = 1;
                    end
                    rowHigh = row + addWidth;
                    if rowHigh > finalDim(1)
                        rowHigh = finalDim(1);
                    end
                    colLow = col - addWidth;
                    if colLow < 1
                        colLow = 1;
                    end
                    colHigh = col + addWidth;
                    if colHigh > finalDim(2)
                        colHigh = finalDim(2);
                    end

                    colorIndex = round(centroidMap(index,1)/spotMax * size(myColorMap,1));
                    if colorIndex == 0
                        colorIndex = 1;
                    end
                    color = myColorMap(colorIndex,:);
                    resampledC(rowLow:rowHigh,colLow:colHigh,1) = color(1);
                    resampledC(rowLow:rowHigh,colLow:colHigh,2) = color(2);
                    resampledC(rowLow:rowHigh,colLow:colHigh,3) = color(3);
                end

            end
            centroidMapsTemp = [centroidMapsTemp,mat2cell(resampledC)];
            chanIndex = chanIndex + 1;
        end
    end
    rnaMaps = chanMapsTemp;
    cellMaps = centroidMapsTemp;
    
    if ishandle(Hs.waitbarH)
        delete(Hs.waitbarH);
    end
end