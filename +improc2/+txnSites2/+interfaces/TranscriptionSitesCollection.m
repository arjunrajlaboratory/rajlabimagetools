classdef TranscriptionSitesCollection < handle
    
    properties
    end
    
    methods (Abstract = true)
        addTranscriptionSite(p, x, y)
        [Xs, Ys] = getTranscriptionSiteXYCoords(p)
        Ints = getTranscriptionSiteInts(p)
        deleteLastTranscriptionSite(p)
        clearAllTranscriptionSites(p)
    end
end

