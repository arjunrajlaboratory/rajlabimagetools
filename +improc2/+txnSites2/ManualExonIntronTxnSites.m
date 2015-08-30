classdef ManualExonIntronTxnSites < improc2.interfaces.NodeData
    %Data for labeling transcription sites when passed an exon and Intron
    %channel. Parent nodes are the fitted data nodes created by our
    %gaussian fitter proc. The node braches from both the exon and intron
    %channel.

    properties
        ExonXs %holds the X positions of the fitted exon spot closest to manualy selected TxnSites
        ExonYs %holds the Y positions of the fitted exon spot closest to manualy selected TxnSites
        Intensity %The amplitude of the Guassian that is fit to the spot located at (ExonXs, ExonYs)
        needsUpdate = true %Update flag
        IntronXs %holds the X positions of the fitted intron spot closest to manualy selected TxnSites
        IntronYs %holds the X positions of the fitted intron spot closest to manualy selected TxnSites
        ColocXs %For each exon spot, check if an intron spot colocalizes and if so add exonX position here
        ColocYs %For each exon spot, check if an intron spot colocalizes and if so add exonY position here
        ColocIntensity % the amplitude of the exon spot for each colocalized spot
    end

    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer',...
            'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'the exon channel to manually inspect', ...
            'the intron channel to manually inspect'};
    end

end