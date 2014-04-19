classdef MinimalPostPostProcessor < improc2.procs.ProcessorData

    
    properties
        numSpots = [];
    end
    
    methods
        function p = MinimalPostPostProcessor(varargin)
            p = p@improc2.procs.ProcessorData(varargin{:});
            p.procDatasIDependOn = {'improc2.tests.MinimalPostProcessor'};
        end
    end
    
    methods (Access = protected)
        function pDataAfterProcessing = runProcessor(pData, proc, varargin)
            pData.numSpots = proc.numSpots;
            pDataAfterProcessing = pData;
        end
    end
    
end

