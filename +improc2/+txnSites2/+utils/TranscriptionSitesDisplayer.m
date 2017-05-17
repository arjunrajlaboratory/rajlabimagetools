classdef TranscriptionSitesDisplayer < handle
%Draws a circle on the selected transcription sites on the image. Currently
%only draws sites at Exon Coordinates - Considered drawing exon and intron,
%but it looked kinda messy
properties (Access = private)
        axH
        transcriptionSitesCollection
        intronExonTxnSitesCollection
        lineHandle
    end
    
    methods
        function p = TranscriptionSitesDisplayer(axH, transcriptionSitesCollection, intronExonTxnSitesCollection)
            p.axH = axH;
            p.transcriptionSitesCollection = transcriptionSitesCollection;
            if nargin > 2
                p.intronExonTxnSitesCollection = intronExonTxnSitesCollection;
            end
        end
        
        function draw(p)
            p.clearGraphics()
            
            [Xs, Ys] = p.transcriptionSitesCollection.getOtherCoordsToDisplayOnInit();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker','o', 'MarkerEdgeColor', 'r', ...
                'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
            
            [Xs, Ys] = p.transcriptionSitesCollection.getTranscriptionSiteXYCoords();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker','o', 'MarkerEdgeColor', 'g', ...
                'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
        end
        
        function drawIntrons(p)
            p.clearGraphics()
%             IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
%             Xs = [];
%             Ys = [];
%             %there may be not intron spots so check
%             if (numel(IntronSpotData) > 0)
%                 for i = 1:numel(IntronSpotData)
%                     Xs = [Xs, IntronSpotData(i).xCenter];
%                     Ys = [Ys, IntronSpotData(i).yCenter];
%                 end
%             end
            [Xs, Ys] = p.transcriptionSitesCollection.getTranscriptionSiteIntronXYCoords();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker','o', 'MarkerEdgeColor', 'r', ...
                'Parent', p.axH, 'HitTest', 'off', 'MarkerSize', 14);
        end
        
        function deactivate(p)
            p.clearGraphics();
        end
        
    end
    
    methods (Access = private)
        function clearGraphics(p)
            if ~isempty(p.lineHandle) && ishandle(p.lineHandle)
                delete(p.lineHandle)
            end
        end
    end
end

