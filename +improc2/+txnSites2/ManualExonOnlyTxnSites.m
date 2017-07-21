classdef ManualExonOnlyTxnSites < improc2.interfaces.NodeData
    %Data for labeling transcription sites when passed an exon 
    %channel. Parent nodes are the fitted data nodes created by our
    %gaussian fitter proc. The node braches from both the channel
    properties
        ClickedXs
        ClickedYs
        Xs %holds the X positions of the fitted exon spot closest to manualy selected TxnSites
        Ys %holds the Y positions of the fitted exon spot closest to manualy selected TxnSites
        Zs
        Intensity %The amplitude of the Guassian that is fit to the spot located at (Xs, Ys)
        needsUpdate = true
    end

    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'the exon channel to manually inspect'};
    end

end