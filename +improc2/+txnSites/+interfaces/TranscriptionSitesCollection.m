classdef TranscriptionSitesCollection < handle
    
    properties
    end
    
    methods (Abstract = true)
        addTranscriptionSite(p, x, y)
        [Xs, Ys] = getTranscriptionSiteXYCoords(p)
        deleteLastTranscriptionSite(p)
        clearAllTranscriptionSites(p)
    end
end

