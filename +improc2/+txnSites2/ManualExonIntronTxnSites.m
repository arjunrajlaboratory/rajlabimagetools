classdef ManualExonIntronTxnSites < improc2.interfaces.NodeData
    %Data for labeling transcription sites when passed an exon and Intron
    %channel. Parent nodes are the fitted data nodes created by our
    %gaussian fitter proc. The node braches from both the exon and intron
    %channel.

    properties
        ClickedXs %holds the X positions of the actual spot clicked by the user
        ClickedYs %holds the y positions of the actual spot clicked by the user
        ExonXs %holds the X positions of the fitted exon spot closest to manualy selected TxnSites
        ExonYs %holds the Y positions of the fitted exon spot closest to manualy selected TxnSites
        ExonZs
        Intensity %The amplitude of the Guassian that is fit to the spot located at (ExonXs, ExonYs)
        needsUpdate = true %Update flag
        IntronXs %holds the X positions of the fitted intron spot closest to manualy selected TxnSites
        IntronYs %holds the X positions of the fitted intron spot closest to manualy selected TxnSites
        IntronZs
        IntronIntensity %holds amplitude of the fitted intron spot closest to manually selected TxnSites
        ColocXs %For each exon spot, check if an intron spot colocalizes and if so add exonX position here
        ColocYs %For each exon spot, check if an intron spot colocalizes and if so add exonY position here
        ColocIntensity % the amplitude of the exon spot for each colocalized spot
        ColocDistances %holds the pdist2 values for all the exons and introns near the clicked points
        TypeTxnSite = {} %Only for intronORexontxnsites stores the kind of txn site
    end

    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer',...
            'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'the exon channel to manually inspect', ...
            'the intron channel to manually inspect'};
    end

end