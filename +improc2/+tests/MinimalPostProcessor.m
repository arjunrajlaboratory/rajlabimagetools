classdef MinimalPostProcessor < improc2.procs.ProcessorData
    
    properties
        numSpots = [];
    end
    
    
    methods
        function pData = MinimalPostProcessor(varargin)
            pData = pData@improc2.procs.ProcessorData(varargin{:});
            pData.procDatasIDependOn = {'improc2.SpotFindingInterface'};
        end
    end
    
    methods (Access = protected)
        function pDataAfterProcessing = runProcessor(pData, spotFindingProc, varargin)
            pData.numSpots = spotFindingProc.getNumSpots;
            pDataAfterProcessing = pData;
        end
    end
    
end

