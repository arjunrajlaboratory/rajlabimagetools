classdef blobConnectionCollectionOneBlobChannelOneTxnSiteChannel < ...
        improc2.interfaces.NodeData & improc2.interfaces.ProcessedData
    
    properties
        distanceToNearestBlob
        areaOfNearestBlob
        centroidsOfNearestBlobX
        centroidsOfNearestBlobY
        majorAxisLengthOfNearestBlob
        minorAxisLengthOfNearestBlob
        eccentricityOfNearestBlob
        extentOfNearestBlob
        perimeterOfNearestBlob
        needsUpdate = true %Update flag
        %         img
    end
    
    properties (Constant = true)
        
%         dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', 'improc2.dataNodes.ChannelStackContainer'};
%         dependencyClassNames = {'improc2.txnSites2.ManualExonIntronTxnSites', 'blobCollectionOneChannel'};
        dependencyClassNames = {'improc2.txnSites2.ManualExonOnlyTxnSites', 'improc2.blobAnalyzer.blobCollectionOneChannel'};
        dependencyDescriptions = {'txn site node', 'speckle channel'};
    end
    
    
    properties
        %         objectHandle %The handle to the image object being view
        dataNodeLabel %Label for blob Node
        txnParentNodeLabels %Label for spot Data parent Nodes
        blobParentNodeLabels
    end
    
     
    methods
        function pDataAfterProcessing = run(p, txnSiteChannel, blobChannel)
%             img = channelStkContainer.zMerge;
            blobMasks = blobChannel.blobMasks;
            X = txnSiteChannel.Xs;
            Y = txnSiteChannel.Ys;
            [area, centroids, majorAxisLength, minorAxisLength,  eccentricity, extent, perimeter] = blobChannel.getBlobProperties();
            [Yrow,Xcol] = find(blobMasks);
            centroidsX = [];
            centroidsY = [];
            distances = [];
            areas = [];
            major = [];
            minor = [];
            ecc = [];
            ext = [];
            per = [];
            for i = 1:length(X)
                if isempty(area)
                    distances = [distances, 'NA'];
                    centroidsX = [centroidsX, 'NA'];
                    centroidsY = [centroidsY, 'NA'];
                    areas = [areas, 'NA'];
                    major = [major, 'NA'];
                    minor = [minor, 'NA'];
                    ecc = [ecc, 'NA'];
                    ext = [ext, 'NA'];
                    per = [per, 'NA'];
                else
                    [idx, dist] = dsearchn([Xcol,Yrow],[X(i), Y(i)]);
                    distances = [distances, dist];
                    Yperim = Yrow(idx);
                    Xperim = Xcol(idx);
                    [idj, distj] = dsearchn([centroids(:,1),centroids(:,2)],[Xperim, Yperim]);
                    centroidsX = [centroidsX, centroids(idj, 1)];
                    centroidsY = [centroidsY, centroids(idj, 2)];
                    areas = [areas, area(idj)];
                    major = [major, majorAxisLength(idj)];
                    minor = [minor, minorAxisLength(idj)];
                    ecc = [ecc, eccentricity(idj)];
                    ext = [ext, extent(idj)];
                    per = [per, perimeter(idj)];
                end
            end
            p.distanceToNearestBlob = distances;
            p.areaOfNearestBlob = areas;
            p.centroidsOfNearestBlobX = centroidsX;
            p.centroidsOfNearestBlobY = centroidsY;
            p.majorAxisLengthOfNearestBlob = major;
            p.minorAxisLengthOfNearestBlob = minor;
            p.eccentricityOfNearestBlob = ecc;
            p.extentOfNearestBlob = ext;
            p.perimeterOfNearestBlob = per;
            pDataAfterProcessing = p;
        end
        
        
        function p = blobConnectionCollectionOneBlobChannelOneTxnSiteChannel(parentNodeLabel1, parentNodeLabel2, varargin)
            ip = inputParser;
%             ip.addParameter('channels', ['gfp', 'cy']);
            ip.addParameter('nodeLabel', 'blobConnections');
            ip.parse(varargin{:});
            %             p.objectHandle = objectHandle;
%             channels = ip.Results.channels;
            
%             p.dataNodeLabel = strcat(channels, ':Blob');
            p.dataNodeLabel = [ip.Results.nodeLabel];
            p.txnParentNodeLabels = parentNodeLabel1;
            p.blobParentNodeLabels = parentNodeLabel2;

        end
        
        
        function out = isvalid(p)
            out = true;
        end
    end
    
    
end