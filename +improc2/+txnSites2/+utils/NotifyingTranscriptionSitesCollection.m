classdef NotifyingTranscriptionSitesCollection < ...
        improc2.txnSites2.interfaces.TranscriptionSitesCollection
%Object to tell the transcriptionSiteCollector of Changes    
    properties (Access = private)
        transcriptionSitesCollection
        actionsOnChangeOfNumTxnSites
    end
    
    methods
        function p = NotifyingTranscriptionSitesCollection(...
                transcriptionSitesCollection)
            p.transcriptionSitesCollection = transcriptionSitesCollection;
            p.actionsOnChangeOfNumTxnSites = ...
                improc2.utils.DependencyRunner();
        end
        
        function addTranscriptionSite(p, x, y)
            p.transcriptionSitesCollection.addTranscriptionSite(x,y);
            p.actionsOnChangeOfNumTxnSites.runDependencies();
        end
        
        function [Xs, Ys] = getTranscriptionSiteXYCoords(p)
            [Xs, Ys] =  p.transcriptionSitesCollection.getTranscriptionSiteXYCoords();
        end
        
        function [Xs, Ys] = getOtherCoordsToDisplayOnInit(p)
            [Xs, Ys] =  p.transcriptionSitesCollection.getOtherCoordsToDisplayOnInit();
        end
        
        function Ints = getTranscriptionSiteInts(p)
            Ints = p.transcriptionSitesCollection.getTranscriptionSiteInts();
        end
        
        function addActionAfterChangeOfNumTxnSites(p, handleToObject, funcToRunOnIt)
            p.actionsOnChangeOfNumTxnSites.registerDependency(...
                handleToObject, funcToRunOnIt);
        end
        
        function deleteLastTranscriptionSite(p)
            p.transcriptionSitesCollection.deleteLastTranscriptionSite();
            p.actionsOnChangeOfNumTxnSites.runDependencies();
        end
        
        function clearAllTranscriptionSites(p)
            p.transcriptionSitesCollection.clearAllTranscriptionSites();
            p.actionsOnChangeOfNumTxnSites.runDependencies();
        end
    end
end

