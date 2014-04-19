close all; clear; clear classes;
myDir = '~/code/dentist_test/3by3';
%myDir = '~/Images/3x3/ProperNames/Small';
%myDir = '~/code/dentist_test/2by2';
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(myDir);
imageDirectoryReader.implementGridLayout(3,3,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);

verboseFlag = false;
[spots, centroids, frequencyTableArray, thresholdsArray] = dentist.findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag);



% Change spots which is a channel-array of spots to a channel-array of
% deletaeble spots
deleteableSpots = dentist.utils.ChannelArray(spots.channelNames);
for channelName = spots.channelNames

    spotObj = spots.getByChannelName(channelName);
    delSpotObj = dentist.utils.DeleteableSpots(spotObj.xPositions, spotObj.yPositions, spotObj.intensities);
    
    % Get median threshold value
    thresholds = [];
    for row = 1:thresholdsArray.Nrows
        for col = 1:thresholdsArray.Ncols
            val = thresholdsArray.getByChannelByPosition(channelName, row, col);
            val = val * 2; % Get the threshold values, not min threshold
            thresholds = [thresholds, val];
        end
    end
    medianThreshold = median(thresholds);    
    % Delete spots that are below the threshold 
    deleteInds = find(spotObj.intensities < medianThreshold);
    delSpotObj = delSpotObj.deleteByIndices(deleteInds);
    
    deleteableSpots = deleteableSpots.setByChannelName(delSpotObj, channelName);
end

delCentroids = dentist.utils.DeleteableCentroids(centroids.xPositions, centroids.yPositions);
spotsAndCentroidsManager = dentist.utils.SpotsAndCentroidsManager(deleteableSpots, delCentroids);

%%
maps = spotsAndCentroidsManager.getRNADensityImages(imageProvider.scanDimensions);
tmrMap = maps.getByChannelName('tmr');

mapsCentroids = spotsAndCentroidsManager.getCentroidMaps(imageProvider.scanDimensions);
tmrMapC = mapsCentroids.getByChannelName('tmr');
%%

        
        colors = {[1,0,0],...%Red
            [0,0,1],...%Orange
            [1,162/255,0],...%Pink
            [1,0,102/255],...%Light-blue
            [101/255,205/255,216/255],...%Purple
            [88/255,11/255,78/255],...%Greenish
            [11/255,88/255,63/255],...
            [216/255,142/255,169/255],...
            [165/255,108/255,8/255]};
        
figure(4);
hold on;
for index = 1:numel(spotsAndCentroidsManager.centroids.xPositions)
    spotSubset = spotsAndCentroidsManager.getSpotsByChannelNameAndCentroidIndex('tmr',index);
    plot(spotSubset.xPositions, spotSubset.yPositions,'.','Color',colors{mod(index,numel(colors)) + 1});
    plot(centroids.xPositions(index), centroids.yPositions(index),'.','Color','b');
end
text(centroids.xPositions, centroids.yPositions,num2str(spotsAndCentroidsManager.getNumSpots));
hold off;


if verboseFlag
    tmrSpots = spots.getByChannelName('tmr');
    figure,plot(tmrSpots.xPositions, tmrSpots.yPositions,'.r');
    hold on, plot(centroids.xPositions, centroids.yPositions,'.');
end

