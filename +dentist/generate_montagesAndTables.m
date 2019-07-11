function [centSpotsOrdFilt] = generate_montagesAndTables(projectDir, wells, channelmap, TNNT2channel, n_output, snapSize)
% If it doesn't exist, creates a new folder called montages in projectDir
% makes a montage (pdf) and associated table (csv)

% projectDir = '/Volumes/IAM-BKUP4/cellid/transdiff/20190612_HCF-942-29-subset/942-29-subset/';
outSubdir = 'montages/';

if ~exist([projectDir outSubdir], 'dir')
    mkdir([projectDir outSubdir])
end

% channelmap.alexa = 'TNNT2';
% channelmap.tmr = 'NPPA';
% channelmap.cy = 'GAPDH';
% channelmap.gfp = 'autofluor';

% wells = [1, 2, 5];


% TNNT2channel = 'alexa'; % must be 'alexa', 'cy', or 'tmr'

% n_output = 50;

% snapSize = 500; % px wide/high per cell image

warning('off','all') % make sure to turn on at end

cd(projectDir)
%% Main loop
% loop through wells


for well = wells
  cd(['w', num2str(well), '_scan'])
  
  outputfile_img = [projectDir, outSubdir, 'w', num2str(well), '_montage.pdf'];
  outputfile_tbl = [projectDir, outSubdir, 'w', num2str(well), '_topCells.csv'];
  
  % load pixel overlap for this well
  loadedConfData = load('dentistConfig.mat');
  nPxOv = loadedConfData.dentistConfig.numPixelOverlap;
  
  % load count and centroid location data
  dataSystem = dentist.buildDataSubystem(dentist.utils.loadData(pwd));
  spotsAndCentroids = dataSystem.spotsAndCentroids;
  centroidLocations = spotsAndCentroids.getCentroids;
  alexanum = spotsAndCentroids.getNumSpotsForCentroids('alexa');
  cynum = spotsAndCentroids.getNumSpotsForCentroids('cy');
  tmrnum = spotsAndCentroids.getNumSpotsForCentroids('tmr');
  
  centroidsAndTheirSpotCounts = table(centroidLocations.xPositions, ...
      centroidLocations.yPositions, ...
      alexanum, ...
      tmrnum, ...
      cynum, ...
      [1:size(tmrnum,1)]');
  centroidsAndTheirSpotCounts.Properties.VariableNames = {'xPos', 'yPos', 'alexa', 'tmr', 'cy', 'cellID'};
  
  % reorder by TNNT2 high-low and filter to top n_output cells
  
  centSpotsOrd = sortrows(centroidsAndTheirSpotCounts, TNNT2channel, 'descend');
  
  centSpotsOrdFilt = centSpotsOrd(1:n_output,:);
  centSpotsOrdFilt.TNNT2rank = (1:n_output)';
  
  
  % loop through each centroid and extract images for top centroids
  tempTileFiles = cell(n_output, 1);
  for i = 1:n_output
      
      % get the tile overlap previously set for this well, initialize file reader
      imageDirectoryReader = dentist.utils.ImageFileDirectoryReader2(pwd);
      imageDirectoryReader.implementGridLayout(25,25,'right','down','snake');
      numPixelOverlap = nPxOv;
      
      % cell summary data (centroid and counts)
      xPosTemp = centSpotsOrdFilt.xPos(i);
      yPosTemp = centSpotsOrdFilt.yPos(i);
      nAlexa = centSpotsOrdFilt.alexa(i);
      nCy = centSpotsOrdFilt.cy(i);
      nTmr = centSpotsOrdFilt.tmr(i);
      
      % initialize image provider setup
      imageProvider = dentist.utils.ImageProvider(imageDirectoryReader, numPixelOverlap);
      viewport = dentist.utils.TileAwareImageViewport2(imageProvider);
      
      % set image size and position in total scan
      viewport.ulCornerXPosition = max(xPosTemp - (snapSize - 1) / 2, 1);
      viewport.ulCornerYPosition = max(yPosTemp - (snapSize - 1) / 2, 1);
      viewport.width = snapSize;
      viewport.height = snapSize;
      
       % extract info
     
       % tile number
      tileTemp = viewport.findTileAtCenter;
      [~, fileTemp, ~] = fileparts(imageDirectoryReader.filePathsGrid{tileTemp.row, tileTemp.col, 3});
      
      % get spot mapping and positions, adjust spot positions for use on overlays
      spotsForPlots.alexa = dataSystem.spotsAndCentroids.getSpots('alexa');
      alexaSpotsMap = dataSystem.spotsAndCentroids.getSpotToCentroidMapping('alexa');
      spotIndsAlexa = alexaSpotsMap' == centSpotsOrdFilt.cellID(i);
      spotsThisCell.alexa.xPositions = spotsForPlots.alexa.xPositions(spotIndsAlexa) - viewport.ulCornerXPosition;
      spotsThisCell.alexa.yPositions = spotsForPlots.alexa.yPositions(spotIndsAlexa) - viewport.ulCornerYPosition;
      
      spotsForPlots.tmr = dataSystem.spotsAndCentroids.getSpots('tmr');
      tmrSpotsMap = dataSystem.spotsAndCentroids.getSpotToCentroidMapping('tmr');
      spotIndsTmr = tmrSpotsMap' == centSpotsOrdFilt.cellID(i);
      spotsThisCell.tmr.xPositions = spotsForPlots.tmr.xPositions(spotIndsTmr) - viewport.ulCornerXPosition;
      spotsThisCell.tmr.yPositions = spotsForPlots.tmr.yPositions(spotIndsTmr) - viewport.ulCornerYPosition;
      
      spotsForPlots.cy = dataSystem.spotsAndCentroids.getSpots('cy');
      cySpotsMap = dataSystem.spotsAndCentroids.getSpotToCentroidMapping('cy');
      spotIndsCy = cySpotsMap' == centSpotsOrdFilt.cellID(i);
      spotsThisCell.cy.xPositions = spotsForPlots.cy.xPositions(spotIndsCy) - viewport.ulCornerXPosition;
      spotsThisCell.cy.yPositions = spotsForPlots.cy.yPositions(spotIndsCy) - viewport.ulCornerYPosition;
      
      % main image extraction and overlay generator
      img.dapi = viewport.getCroppedImage(imageProvider, 'dapi');
      img.alexa = viewport.getCroppedImage(imageProvider, 'alexa');
      img.tmr = viewport.getCroppedImage(imageProvider, 'tmr');
      img.cy = viewport.getCroppedImage(imageProvider, 'cy');
      img.gfp = viewport.getCroppedImage(imageProvider, 'gfp');
      
      imgadj.dapi = imadjust(img.dapi, stretchlim(img.dapi,[0.96 1]));
      imgadj.alexa = imadjust(img.alexa, stretchlim(img.alexa,[0.07 0.995]));
      imgadj.tmr = imadjust(img.tmr, stretchlim(img.tmr,[0.07 0.995]));
      imgadj.cy = imadjust(img.cy, stretchlim(img.cy,[0.00 0.995]));
      imgadj.gfp = imadjust(img.gfp, stretchlim(img.gfp,[0.00 0.995]));
      
      overlay.alexa = cat(3, imgadj.alexa, imgadj.alexa, (imgadj.alexa + imgadj.dapi));
      overlay.tmr = cat(3, imgadj.tmr, imgadj.tmr, (imgadj.tmr + imgadj.dapi));
      overlay.cy = cat(3, imgadj.cy, imgadj.cy, (imgadj.cy + imgadj.dapi));
      overlay.gfp = cat(3, imgadj.gfp, imgadj.gfp, (imgadj.gfp + imgadj.dapi));
      
      % plot everything together
      figure('units','inch','position',[0,0,16*1.2,9*1.2]);
      
      subplot(2,4,1), subimage(overlay.tmr), title(['tmr - ', channelmap.tmr, ' - "', num2str(nTmr), ' spots"'])
      subplot(2,4,2), subimage(overlay.alexa), title(['alexa - ', channelmap.alexa, ' - "', num2str(nAlexa), ' spots"'])
      subplot(2,4,3), subimage(overlay.cy), title(['cy - ', channelmap.cy, ' - "', num2str(nCy), ' spots"'])
      subplot(2,4,4), subimage(overlay.gfp), title(['gfp - ', channelmap.gfp])
      
      subplot(2,4,5), subimage(overlay.tmr), hold on, plot(spotsThisCell.tmr.xPositions, spotsThisCell.tmr.yPositions, 'wo','markersize',10), hold off
      subplot(2,4,6), subimage(overlay.alexa), hold on, plot(spotsThisCell.alexa.xPositions, spotsThisCell.alexa.yPositions, 'wo','markersize',10), hold off
      subplot(2,4,7), subimage(overlay.cy), hold on, plot(spotsThisCell.cy.xPositions, spotsThisCell.cy.yPositions, 'wo','markersize',10), hold off
      subplot(2,4,8), subimage(overlay.gfp), title(['gfp - ', channelmap.gfp])
      
      suptitle(['Cell ranked #', num2str(i), ' by TNNT2. In tile ', fileTemp, '. Well ', num2str(well)])
      
      set(gcf, 'Color', 'w');
      
      export_fig(outputfile_img, '-append')
      
      tempTileFiles{i, 1} = fileTemp;
      
      close(gcf)
      
  end % cells
  
  centSpotsOrdFilt.tileName = tempTileFiles;
  writetable(centSpotsOrdFilt, outputfile_tbl)
  
  cd(projectDir)
  
end % well


%%
warning('on','all')

end

