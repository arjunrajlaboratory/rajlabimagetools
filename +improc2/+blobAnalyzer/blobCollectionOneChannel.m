classdef blobCollectionOneChannel < ...
        improc2.interfaces.blobCollection & improc2.interfaces.NodeData & improc2.interfaces.ProcessedData
    
    properties
        
        spotNodeLabels
        nucleusArea
        totalBlobArea
        totalBlobPerimeter
        numberOfBlobs
        blobCentroidsX
        blobCentroidsY
        blobAreas
        blobEccentricities
        blobPerimeters
        blobExtents
        blobMasks
        notBlobNucleusMask
        needsUpdate = true %Update flag
        %         img
    end
    
    properties (Constant = true)
        
%         dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', 'improc2.dataNodes.ChannelStackContainer'};
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', 'improc2.nodeProcs.RegionalMaxProcessedData', 'improc2.nodeProcs.DapiProcessedData'};
        dependencyDescriptions = { 'speckle channel', 'image source', 'dapi source'};
    end
    
    
    properties
        %         objectHandle %The handle to the image object being view
        dataNodeLabel %Label for blob Node
        parentNodeLabels %Label for spot Data parent Nodes
        
    end
    
    
    
    methods
        function pDataAfterProcessing = run(p, fittedSpots, channelStkContainer, dapiData)
            img = channelStkContainer.zMerge;
            p.blobMasks = getBlobMasks(p, fittedSpots, img);
            p.notBlobNucleusMask = getNotBlobNucleusMask(p, p.blobMasks, dapiData);
            p.nucleusArea = getNuclearArea(p, dapiData);
            p.totalBlobArea = sum(p.blobMasks, 'all');
            [area, centroids, majorAxisLength, minorAxisLength,  eccentricity, extent, perimeter, numBlobs] = getBlobProperties(p);
            p.blobCentroidsX = centroids(:,1);
            p.blobCentroidsY = centroids(:,2);
            p.blobAreas = area;
            p.blobEccentricities = eccentricity;
            p.blobExtents = extent;
            p.blobPerimeters = perimeter;
%             p.totalBlobArea = sum(area);
            p.totalBlobPerimeter = sum(perimeter);
            p.numberOfBlobs = numBlobs;
            pDataAfterProcessing = p;
        end
        
        
        function p = blobCollectionOneChannel(varargin)
            ip = inputParser;
            ip.addParameter('channels', 'gfp');
            ip.addParameter('nodeLabel', []);
%            ip.addParameter('dapiNode', 'dapiProc');
            ip.parse(varargin{:});
            %             p.objectHandle = objectHandle;
            channels = ip.Results.channels;
            
%             p.dataNodeLabel = strcat(channels, ':Blob');
            if isempty(ip.Results.nodeLabel)
                p.dataNodeLabel = strcat(channels, ':Blob');
            else
                p.dataNodeLabel = [ip.Results.nodeLabel];
            end
            
            
            p.parentNodeLabels = {};
%             p.percentMax = ip.Results.percentMax;
            for i = channels
                p.parentNodeLabels = [p.parentNodeLabels, strcat(i, ':Fitted')];
            end
%             p.parentNodeLabels = [p.parentNodeLabels, 'dapi'];
                
            for i = channels
                p.spotNodeLabels = [p.spotNodeLabels, strcat(i, ':Spots')];
            end
        end
        
        
        function out = isvalid(p)
            out = true;
        end

        
        function blobMasks = getBlobMasks(p, fittedSpots, im)
            
%             blobMasks = zeros(size(im));
            X = [];
            Y = [];
            X = [X, fittedSpots.getFittedSpots.xCenter];
            Y = [Y, fittedSpots.getFittedSpots.yCenter];

            im = scale(im);
            imbw = imbinarize(im);
%             imbw
%             imshow(imbw)
            imbw_selected = bwselect(imbw, X, Y);
            blobMasks = imbw_selected;
        end
        
        function notBlobNucleusMask = getNotBlobNucleusMask(p, blobMasks, dapiData)
            nuclearMask = dapiData.mask;
            notBlobNucleusMask = ~(~nuclearMask + blobMasks);   
        end

        function nuclearArea = getNuclearArea(p, dapiData)
            nuclearMask = dapiData.mask;
            nuclearArea = sum(nuclearMask, 'all');
        end

        
        function [area, centroids, majorAxisLength, minorAxisLength,  eccentricity, extent, perimeter, numBlobs] = getBlobProperties(p)
            H = vision.BlobAnalysis('AreaOutputPort', true, 'CentroidOutputPort', true, 'BoundingBoxOutputPort', ...
            false, 'MajorAxisLengthOutputPort', true, 'MinorAxisLengthOutputPort', true, 'EccentricityOutputPort', ...
            true, 'ExtentOutputPort', true, 'PerimeterOutputPort', true, 'LabelMatrixOutputPort', 150, 'MaximumCount', 150);
            [area, centroids, majorAxisLength, minorAxisLength,  eccentricity, extent, perimeter] = step(H, p.blobMasks);
            numBlobs = length(area);
        end
        
        function showBlobs(p)
            mask = p.objectHandle.getData(p.dataNodeLabel).blobMasks;
            imshow(mask);
        end
        
        function flagAsReviewed(p)
            data = p.objectHandle.getData({p.dataNodeLabel});
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end
