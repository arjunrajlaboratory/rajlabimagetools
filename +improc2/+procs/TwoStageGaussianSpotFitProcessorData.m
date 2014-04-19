classdef TwoStageGaussianSpotFitProcessorData < improc2.procs.ProcessorData & ...
        improc2.interfaces.FittedSpotsContainer
    
    properties (GetAccess = public, SetAccess = private)
        filterParams
        imageFilterFunc
    end
    
    properties (Access = private)
        storedFittedSpots
        storedFittedBackgLevels
    end
    
    methods
        function pData = TwoStageGaussianSpotFitProcessorData(varargin)
            pData.procDatasIDependOn = {'improc2.SpotFindingInterface'};
            pData.description = sprintf(...
                ['Fit Gaussians to images\n', ...
                'at locations specified by an earlier spot finding processor']);
            
            pData.filterParams = improc2.aTrousFilterParams(struct('sigma',0.5,'numLevels',3));
            pData.imageFilterFunc = @improc2.utils.applyATrousImageFilter;
            
            ip = inputParser;
            ip.addOptional('filterParams', struct(), @isstruct);
            ip.parse(varargin{:});
            
            pData.filterParams = pData.filterParams.replaceParams( ip.Results.filterParams );
        end
        
        function spots = getFittedSpots(pData)
            spots = pData.storedFittedSpots;
        end
        
        function backgLevels = getFittedBackgLevels(pData)
            backgLevels = pData.storedFittedBackgLevels;
        end
        
    end
    
    methods (Access = protected)
        function pDataAfterProcessing = runProcessor(pData, spotProvidingProcessor, varargin)
            [Is, Js, Ks] = spotProvidingProcessor.getSpotCoordinates();
            Xs = Js;
            Ys = Is;
            Zs = Ks;
            
            croppedImg = improc2.getArgsForClassicProcessor(varargin{:});
            filteredImg = pData.imageFilterFunc(croppedImg, pData.filterParams);
            
            fprintf('Fitting ...\n')
            [pData.storedFittedSpots, pData.storedFittedBackgLevels] = ...
                improc2.fitting.fitSpotPositionsThenRefineForAmplitude(...
                    filteredImg, croppedImg, Xs, Ys, Zs);
            pDataAfterProcessing = pData;
        end 
    end
    
end

