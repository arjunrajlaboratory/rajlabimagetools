classdef TwoStageSpotFitProcessedData < improc2.interfaces.ProcessedData & ...
        improc2.interfaces.FittedSpotsContainer
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.SpotsProvider', ...
            'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'initial Spot Guesses', 'image source'};
    end
    
    properties (GetAccess = public, SetAccess = private)
        filterParams
        imageFilterFunc
    end
    
    properties (Access = private)
        storedFittedSpots
        storedFittedBackgLevels
    end
    
    methods
        function pData = TwoStageSpotFitProcessedData(varargin)
            
            pData.filterParams = improc2.aTrousFilterParams(struct('sigma',0.5,'numLevels',3));
            pData.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            ip = inputParser;
            ip.addOptional('filterParams', struct(), @isstruct);
            ip.parse(varargin{:});
            
            pData.filterParams = pData.filterParams.replaceParams( ip.Results.filterParams );
        end
        
        function pDataAfterProcessing = run(pData, spotsProvider, channelStackContainer)
            
            if isempty(spotsProvider.getSpotCoordinates())
            spots = improc2.fitting.Gaussian2dSpot.empty;
            pData = setFittedSpots(pData, spots); 
            pData = setFittedBackgLevels(pData, spotsProvider.getSpotCoordinates());
            pDataAfterProcessing = pData;
            else
            
            [Is, Js, Ks] = spotsProvider.getSpotCoordinates();
            Xs = Js;
            Ys = Is;
            Zs = Ks;
            
            croppedImg = channelStackContainer.croppedImage;
            filteredImg = pData.imageFilterFunc(croppedImg, pData.filterParams);
            
            fprintf('Fitting ...\n')
            [pData.storedFittedSpots, pData.storedFittedBackgLevels] = ...
                improc2.fitting.fitSpotPositionsThenRefineForAmplitude(...
                filteredImg, croppedImg, Xs, Ys, Zs);
            pDataAfterProcessing = pData;
            
            end
        end
        
        function spots = getFittedSpots(pData)
            spots = pData.storedFittedSpots;
        end
        
        function pData = setFittedSpots(pData, spots)
            pData.storedFittedSpots = spots;
        end
        
        function backgLevels = getFittedBackgLevels(pData)
            backgLevels = pData.storedFittedBackgLevels;
        end
        
        function pData = setFittedBackgLevels(pData, backgLevels)
            pData.storedFittedBackgLevels = backgLevels;
        end
        
    end
end

