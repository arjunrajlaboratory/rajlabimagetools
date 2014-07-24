classdef IntronExonTranscriptionSitesCollection < ...
        opm.txnsites.interfaces.TranscriptionSitesCollection
    
    properties (Access = private)
        objectHandle
        dataNodeLabel
    end
    
    methods
        
        function p = IntronExonTranscriptionSitesCollection(objectHandle, dataNodeLabel)
            p.objectHandle = objectHandle;
            p.dataNodeLabel = dataNodeLabel;
        end
        
        function addTranscriptionSite(p, x, y)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.Xs = [data.Xs; x];
            data.Ys = [data.Ys; y];
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function [Xs, Ys] = getTranscriptionSiteXYCoords(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Xs = data.Xs;
            Ys = data.Ys;
        end
        
        function deleteLastTranscriptionSite(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            if length(data.Xs) < 2
                data.Xs = [];
                data.Ys = [];
            else
                data.Xs = data.Xs(1:(end-1));
                data.Ys = data.Ys(1:(end-1));
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function clearAllTranscriptionSites(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.Xs = [];
            data.Ys = [];
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end

