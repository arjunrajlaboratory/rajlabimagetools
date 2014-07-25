classdef ManualExonIntronTxnSites < improc2.interfaces.NodeData

    properties
        Xs
        Ys
        needsUpdate = true
    end

    properties (Constant = true)
        dependencyClassNames = {'improc2.dataNodes.ChannelStackContainer',...
            'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'the exon channel to manually inspect', ...
            'the intron channel to manually inspect'};
    end

end