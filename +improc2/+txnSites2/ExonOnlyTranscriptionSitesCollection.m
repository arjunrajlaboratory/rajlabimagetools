classdef ExonOnlyTranscriptionSitesCollection < ...
        improc2.txnSites2.interfaces.TranscriptionSitesCollection
%Object that interacts with the ExonOnly TxnSite Data Nodes   
    properties (Access = private)
        objectHandle
        dataNodeLabel
        parentNodeLabels
    end
    
    methods
        %Create the object
        function p = ExonOnlyTranscriptionSitesCollection(objectHandle, exonChannel)
            p.objectHandle = objectHandle;
            p.dataNodeLabel = [exonChannel, ':TxnSites'];
            p.parentNodeLabels = {[exonChannel ':Fitted'], };
        end
        %Add a transcription site to the image object data. Finds the exon
        %site closest to where you clicked on the GUI and adds its
        %coordinates and corresponding fitted amplitude.
        function addTranscriptionSite(p, x, y)
            data = p.objectHandle.getData(p.dataNodeLabel);
            spotData = p.objectHandle.getData(p.parentNodeLabels).getFittedSpots;
            fittedXs = [];
            fittedYs = [];
            intensities = [];
            for i = 1:numel(spotData)
                fittedXs = [fittedXs, spotData(i).xCenter];
                fittedYs = [fittedYs, spotData(i).yCenter];
                intensities = [intensities, spotData(i).amplitude];
            end
            nn = knnsearch([fittedXs', fittedYs'], [x,y]);
            data.Xs = [data.Xs; fittedXs(nn)];
            data.Ys = [data.Ys; fittedYs(nn)];
            data.Intensity = [data.Intensity, intensities(nn)];
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function [Xs, Ys] = getTranscriptionSiteXYCoords(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Xs = data.Xs;
            Ys = data.Ys;
        end
        
        function Ints = getTranscriptionSiteInts(p)
            data = p.objectHandle.getData(p.dapaNodeLabel);
            Ints = data.Ints;
        end
        
        function deleteLastTranscriptionSite(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            if length(data.Xs) < 2
                data.Xs = [];
                data.Ys = [];
                data.Intensity = [];
            else
                data.Xs = data.Xs(1:(end-1));
                data.Ys = data.Ys(1:(end-1));
                data.Intensity = data.Intensity(1:(end-1));
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function clearAllTranscriptionSites(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.Xs = [];
            data.Ys = [];
            data.Intensity = [];
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function flagAsReviewed(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end

