classdef ManuallySelectedPointsData < improc2.procs.ProcessorData
    
    properties (Access = private)
        Xs = [];
        Ys = [];
        Zs = [];
    end
    
    methods
        function pData = ManuallySelectedPointsData()
            pData = run(pData);
        end
        
        function pData = addPoint(pData, X, Y, Z)
            pData.Xs = [pData.Xs; X];
            pData.Ys = [pData.Ys; Y];
            pData.Zs = [pData.Zs; Z];
        end
        
        function XYZs = getPoints(pData)
            XYZs = [pData.Xs, pData.Ys, pData.Zs];
        end
        
        function pData = removeLastPoint(pData)
            pData.Xs = pData.Xs(1:end-1);
            pData.Ys = pData.Ys(1:end-1);
            pData.Zs = pData.Zs(1:end-1);
        end
    end
end

