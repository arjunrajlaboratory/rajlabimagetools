classdef SpotsAndCentroidsManager
    properties (SetAccess = private)
        centroids % DeleteableCentroids
        centroidToNumSpotsMappings % ChannelArray
        spots    % ChannelArray of DeleteableSpots
        spotToCentroidMappings % ChannelArray
        maxDistance = 1024;
    end
    properties (Dependent = true)
        availableChannels
    end
    
    methods
        function p = SpotsAndCentroidsManager(spots, centroids)
            if ~isa(spots, 'dentist.utils.ChannelArray') ||...
                    ~isa(centroids, 'dentist.utils.DeleteableCentroids')
                error (['First input must be of type ChannelArray',...
                    'and second input of type DeleteableCentroids']);
            end
            p.spots = spots;
            p.centroids = centroids;
            p = p.initializeSpotAndCentroidAssignment();
        end
        function channelNames = get.availableChannels(p)
            channelNames = p.spots.channelNames;
        end
        function p = deleteCentroidsAndSpotsByROI(p, roi)
            
        end
        function spots = getSpotsByChannelNameAndCentroidIndex(p, channelName, centroidIndex)
            spotsObj = p.spots.getByChannelName(channelName);
            assignedCentroids = p.spotToCentroidMappings.getByChannelName(channelName);
            indices = find(assignedCentroids == centroidIndex);
            spots = spotsObj.subsetByIndices(indices);
        end
        function list = getNumSpotsList(p, varargin)
            % Have manager remember latest filter
        end
        function centroidMaps = getCentroidMaps(p, scanDimensions)
            centroidMaps = dentist.utils.ChannelArray(p.spots.channelNames);
            % size of final image - number of "bins" which larger image
            % will have to funnel into
            finalDim = [1000 1000];
            % scaling factor
            scale = scanDimensions ./ finalDim;
            myColorMap = colormap(jet(255));
            
            for channelName = p.spots.channelNames
                numSpotsForChannel = p.numSpots.getByChannelName(channelName);
                % Create canvas
                resampledC = zeros([finalDim,3]);
                spotMax = max(numSpotsForChannel);
                list = [p.centroids.yPositions,p.centroids.xPositions, numSpotsForChannel];
                [list, ~] = sortrows(list, 3);
                % Flip to descending order
                list = flipud(list);
                
                for index = 1:size(list,1)
                    addWidth = 3;
                    ind = list(index, 1:2);
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
                    
                    colorIndex = round(list(index,3)/spotMax * size(myColorMap,1));
                    if colorIndex == 0
                        colorIndex = 1;
                    end
                    color = myColorMap(colorIndex,:);
                    resampledC(rowLow:rowHigh,colLow:colHigh,1) = color(1);
                    resampledC(rowLow:rowHigh,colLow:colHigh,2) = color(2);
                    resampledC(rowLow:rowHigh,colLow:colHigh,3) = color(3);
                end
                centroidMaps = centroidMaps.setByChannelName(resampledC, channelName);
            end
            
        end
        % Scan dimensions are [row_width, col_width]
        function rnaDensityMaps = getRNADensityImages(p, scanDimensions)
            display(scanDimensions);
            row_width = scanDimensions(1);
            col_width = scanDimensions(2);
            rnaDensityMaps = dentist.utils.ChannelArray(p.spots.channelNames);
            for channelName = p.spots.channelNames
                finalDim = [1000 1000];
                % Create canvas
                resampledS = zeros(finalDim);
                % scaling factor
                scale = scanDimensions ./ finalDim;
                spotsObj = p.spots.getByChannelName(channelName);
                numSpotSet = p.numSpots.getByChannelName(channelName);
                % Iterate over each spot
                for index = 1:numel(spotsObj.xPositions)
                    ind = [spotsObj.yPositions(index), spotsObj.xPositions(index)];
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
                    if rowHighO > row_width
                        rowHighO = row_width;
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
                    if colHighO > col_width
                        colHighO = col_width;
                    end
                    % Convert to scaled image coordinates
                    colHigh = floor((colHighO - 1) / scale(2)) + 1;
                    %----------------------------------------------------------
                    %Find the number of spots attributed to the centroid for
                    %which this spot is attributed to
                    centroidIndiceSet = p.spotToCentroidMappings.getByChannelName(channelName);
                    centroidIndex = centroidIndiceSet(index);
                    value = numSpotSet(centroidIndex);
                    display(value);
                    resampledS(rowLow:rowHigh,colLow:colHigh) = resampledS(rowLow:rowHigh,colLow:colHigh) + value;
                end
                rgbImage = p.getRGBFromRNADensityIntensityMap(resampledS, scale);
                rnaDensityMaps = rnaDensityMaps.setByChannelName(rgbImage, channelName);
            end
            % Get the subset of spots and spotmap for which the intensity
            % values are above the threshold
        end
    end
    methods (Access = private)
        function rgb = getRGBFromRNADensityIntensityMap(p, resampledS, scale)
            %The indices of the zeros in the image
            zeroINDs = (resampledS == 0);
            centInts = [];
            for index = 1:size(p.centroids.xPositions)
                loc = [p.centroids.yPositions(index), p.centroids.xPositions(index)];
                % Scale to small image coordinates
                loc(1) = floor((loc(1) - 1) / scale(1) + 1);
                loc(1) = max(loc(1),1);
                loc(2) = floor((loc(2) - 1) / scale(2) + 1);
                loc(2)  = max(loc(2),1);
                centInts = [centInts,resampledS(loc)];
            end
            [vals,~] = sort(centInts);
            % The bottom 85% of value will all have the same color.
            % Everything below the cutOff is being given the same value to
            % ensure the colormap is being utilized on the top intensity
            % values
            cutOff = vals(round(numel(centInts) * 0.85));
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
        end
        function p = initializeSpotAndCentroidAssignment(p)
            [p.spotToCentroidMappings, p.spots] = ...
                p.spots.applyForEachChannel(...
                    @dentist.utils.assignSpotsToCentroids, ...
                    p.centroids, p.maxDistance);
        end
        function p = calculateNumSpotsForCentroids(p)
            p.centroidToNumSpotsMappings = ...
                p.spotToCentroidMappings.applyForEachChannel(...
                    @dentist.utils.calculateNumSpotsForCentroids, ...
                    p.centroids);
        end
        function p = updateSpotAndCentroidAssignment(p)
            
        end
    end
    
    
    
end
