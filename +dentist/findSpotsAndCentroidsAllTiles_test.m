dentist.tests.cleanupForTests;
% myDir = '~/code/dentist_test/3by3';
myDir = '~/code/dentist_test/2by2';
imageDirectoryReader = dentist.utils.ImageFileDirectoryReader(myDir);
imageDirectoryReader.implementGridLayout(2,2,'down','right','nosnake');
numPixelOverlap = 103;
imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);

verboseFlag = false;
[spots, centroids, frequencyTableArray] = dentist.findSpotsAndCentroidsAllTiles(imageProvider, verboseFlag);

if verboseFlag % works only for the 3by3 case.
    imreadTMR =  @(x) imread(strcat(myDir, '/', 'tmr', x, '.tif'));
    
    img1 = imreadTMR('001');
    img1 = img1(1:end-numPixelOverlap,1:end-numPixelOverlap);
    img2 = imreadTMR('002');
    img2 = img2(1:end-numPixelOverlap,1:end-numPixelOverlap);
    img3 = imreadTMR('003');
    img3 = img3(1:end,1:end-numPixelOverlap);
    img4 = imreadTMR('004');
    img4 = img4(1:end-numPixelOverlap,1:end-numPixelOverlap);
    img5 = imreadTMR('005');
    img5 = img5(1:end-numPixelOverlap,1:end-numPixelOverlap);
    img6 = imreadTMR('006');
    img6 = img6(1:end,1:end-numPixelOverlap);
    img7 = imreadTMR('007');
    img7 = img7(1:end-numPixelOverlap,1:end);
    img8 = imreadTMR('008');
    img8 = img8(1:end-numPixelOverlap,1:end);
    img9 = imreadTMR('009');
    img9 = img9(1:end,1:end);
    
    catImg = [[img1; img2; img3], [img4; img5; img6], [img7; img8; img9]];
    figure,imshow(imadjust(catImg),'InitialMagnification','fit');
    hold on;
    plot(centroids.xPositions, centroids.yPositions, '.','Color','r');
end    

tmrSpots = spots.getByChannelName('tmr');
figure,plot(tmrSpots.xPositions, tmrSpots.yPositions,'.r');
hold on, plot(centroids.xPositions, centroids.yPositions,'.');

