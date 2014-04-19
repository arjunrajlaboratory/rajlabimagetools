classdef TwoChannelSpotSumProc < improc2.procs.ProcessorData & improc2.SpotFindingInterface
    
    properties
        numSpots = [];
        I;
        J;
        K;
    end
    
    methods
        function pData = TwoChannelSpotSumProc(varargin)
            pData = pData@improc2.procs.ProcessorData(varargin{:});
            pData.procDatasIDependOn = ...
                {'improc2.SpotFindingInterface',...
                'improc2.SpotFindingInterface'};
        end 
        
        function n = getNumSpots(pData)
            n = pData.numSpots;
        end
        
        function [I, J, K] = getSpotCoordinates(pData)
            I = pData.I;
            J = pData.J;
            K = pData.K;
        end
    end
    
    methods (Access = protected)
        function pDataAfterProcessing = runProcessor(pData, spotproc1, spotproc2)
            pData.numSpots = spotproc1.getNumSpots() + spotproc2.getNumSpots();
            [I1,J1,K1] = spotproc1.getSpotCoordinates();
            [I2,J2,K2] = spotproc2.getSpotCoordinates();
            pData.I = [I1; I2];
            pData.J = [J1; J2];
            pData.K = [K1; K2];
            pDataAfterProcessing = pData;
        end
    end
    
end

