classdef TranscriptionSiteAddingInterpreter < dentist.utils.MouseGestureInterpreter
%Object to interpret where the user clicked on the graph and pass the cords
%to the transcriptionCollection
    properties (Access = private)
        transcriptionSitesCollection
    end
    
    methods
        function p = TranscriptionSiteAddingInterpreter(transcriptionSitesCollection)
            p.transcriptionSitesCollection = transcriptionSitesCollection;
        end
        
        function doAfterButtonUp(p, varargin)
            [x, y] = p.determineClickedPoint();
            p.transcriptionSitesCollection.addTranscriptionSite(x, y);
        end
    end
    
    methods (Access = private)
        function [x, y] = determineClickedPoint(p)
            currentPoint = get(p.axH, 'CurrentPoint');
            xLimits = xlim(p.axH);
            yLimits = ylim(p.axH);
            x = max(min(currentPoint(1,1), xLimits(2)), xLimits(1));
            y = max(min(currentPoint(1,2), yLimits(2)), yLimits(1));
        end
    end
end

