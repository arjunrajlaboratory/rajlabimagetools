classdef MockFittedSpotsProcessorData < improc2.procs.ProcessorData & ...
        improc2.interfaces.FittedSpotsContainer
    properties (Access = private)
        spots
    end
    
    methods
        function pData = MockFittedSpotsProcessorData(spots)
            pData.spots = spots;
            pData = run(pData);
        end
        
        function spots = getFittedSpots(pData)
            spots = pData.spots;
        end
    end    
end

