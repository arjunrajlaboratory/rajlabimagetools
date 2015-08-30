classdef TranscriptionSitesDisplayer < handle
%Draws a circle on the selected transcription sites on the image. Currently
%only draws sites at Exon Coordinates - Considered drawing exon and intron,
%but it looked kinda messy
properties (Access = private)
        axH
        transcriptionSitesCollection
        lineHandle
    end
    
    methods
        function p = TranscriptionSitesDisplayer(axH, transcriptionSitesCollection)
            p.axH = axH;
            p.transcriptionSitesCollection = transcriptionSitesCollection;
        end
        
        function draw(p)
            p.clearGraphics()
            [Xs, Ys] = p.transcriptionSitesCollection.getTranscriptionSiteXYCoords();
            p.lineHandle = line(Xs, Ys, ...
                'LineStyle', 'none', ...
                'Marker','o', 'MarkerEdgeColor', 'g', ...
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

