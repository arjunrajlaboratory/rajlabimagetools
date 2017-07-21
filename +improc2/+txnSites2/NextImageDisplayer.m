classdef NextImageDisplayer < handle
    %Object to display the image for the next object. Have to handle it
    %this way, the navigatorGUI handles object changes using the method
    %'addActionAfterMoveAttempt' which requires an object and a method in
    %that object to call. We can't just pass the method as you would for a
    %callback function
    properties
        imageHolders
        imgAx
        baseTxnSitesCollection
        channelSelect
        paramsForComposite
    end
    methods
        function p = NextImageDisplayer(imageHolders, paramsForComposite, imgAx, baseTxnSitesCollection, channelSelect)
            p.imageHolders = imageHolders;
            p.imgAx = imgAx;
            p.baseTxnSitesCollection = baseTxnSitesCollection;
            p.channelSelect = channelSelect;
            p.paramsForComposite = paramsForComposite;
        end
        function nextImageDisplay(p)
            Popitems = get(p.channelSelect ,'String');
            Popindex_selected = get(p.channelSelect,'Value');
            Popitem_selected = Popitems{Popindex_selected};
            compositeImageMaker = improc2.txnSites2.CompositeImageMaker(p.imageHolders.exon, ...
                p.imageHolders.intron, p.imageHolders.dapi, p.imageHolders.otherChannels, p.paramsForComposite, ...
                Popitem_selected);
            sizeAdaptiveViewportHolder = improc2.utils.ImageSizeAdaptiveViewportHolder(p.imageHolders.intron);
            viewportHolder = improc2.utils.NotifyingViewportHolder(sizeAdaptiveViewportHolder);
            
            compositeImageDisplayer = improc2.utils.ImageDisplayer(p.imgAx, compositeImageMaker, viewportHolder);
            txnSitesCollection = improc2.txnSites2.utils.NotifyingTranscriptionSitesCollection(...
                p.baseTxnSitesCollection);
            
            txnSitesDisplayer = improc2.txnSites2.utils.TranscriptionSitesDisplayer(p.imgAx, txnSitesCollection, p.baseTxnSitesCollection);
            
            mainWindowDisplayer = dentist.utils.DisplayerSequence(...
                compositeImageDisplayer, txnSitesDisplayer);
            
            mainWindowDisplayer.draw();
        end
    end
        
        
end