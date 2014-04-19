function [spotsByChannel, spotFrequencyTables, thresholdsByChannel] =...
    findSpotsInTile(imageProvider, verboseFlag)
    if nargin < 2
        verboseFlag = false;
    end
    
    fishChannelNames = imageProvider.availableFishChannels;
    
    spotsByChannel = dentist.utils.ChannelArray(fishChannelNames);
    spotFrequencyTables = dentist.utils.ChannelArray(fishChannelNames);
    thresholdsByChannel = dentist.utils.ChannelArray(fishChannelNames);
    
    for channelName = fishChannelNames
        img = imageProvider.getImageFromChannel(channelName);
        
        [spots, frequencyTable, threshold] = processForSpots(img);
        
        spotsByChannel = spotsByChannel.setByChannelName(spots, channelName);
        spotFrequencyTables = spotFrequencyTables.setByChannelName(frequencyTable, channelName);
        thresholdsByChannel = thresholdsByChannel.setByChannelName(threshold, channelName);
        
        if verboseFlag
            figure(2);
            imshow(imadjust(img),'InitialMagnification','fit');
            plotCirclesAtCoordinates(spots.xPositions,spots.yPositions);
        end
    end

end
function plotCirclesAtCoordinates(x, y)
    hold on;
    plot(x,y,'or');
    hold off;
end
function [spots, frequencyTable, minThreshold] = processForSpots(img)

    % Leftmost column is dark and results in spots being detected.  This
    % column is removed
    img = img(:,2:end);
    
    %Filters out low frequency noise
    %Deconstruct into frequency ranges
    [aTrous, ~] = aTrousWaveletTransform(img,'numLevels',3,'sigma',2);
    %Reconstructing image without low frequencies by summing across third
    %dimension (the frequency dimension)
    imgAT = sum(aTrous,3);
    %imshow(imgAT>100);
    % find regional maxima in segmented image
    % bw is an array the same size as the image which contains 1's and 0's
    % 1 if it is a regionalmax and 0 if it is not
    bw = imregionalmax(imgAT);
    regionalMaxValues = imgAT(bw);

    regionalMaxIndices = find(bw);
    %Sort in ascending order
    [regionalMaxValues,I] = sort(regionalMaxValues,'ascend');
   % display(Hs.regionalMaxValues);
    regionalMaxIndices = regionalMaxIndices(I);
    %Auto threshold
    [threshold] = imregmaxThresh(regionalMaxValues);
    if isempty(threshold)
        threshold = max(regionalMaxValues) + 1; %beyond max
    end
    %Dividing the auto-threshold by 2 in order to get all spots that would
    %reasonably be desired.  This avoids having to reprocess every time
    %user adjusts the threshold
    
    % Includes intensities even for those below the cutoff threshold value
    frequencyTable = dentist.utils.SpotFrequencyTable(regionalMaxValues);
    

    spotInds = regionalMaxIndices(regionalMaxValues>(threshold/2));
    spotInt = regionalMaxValues(regionalMaxValues>(threshold/2));
    
    [row,col] = ind2sub(size(bw),spotInds);  % convert 1D to 2D
    %Convert to absolute values
   %%%%%%%%% row = row + ((Hs.tileRow-1) * (Hs.imageSize(1) - Hs.overlap));
    %%%%%%%col = col + ((Hs.tileCol-1) * (Hs.imageSize(2) - Hs.overlap));

    % Since the leftmost column was deleted, add one to column indice to
    % ensure proper coordinates
    %%%%%%%%%col = col + 1;
    minThreshold = threshold/2;
    spots = dentist.utils.Spots(col, row, spotInt);
end


