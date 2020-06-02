classdef blobIntensityOneChannel < ...
        improc2.interfaces.blobCollection & improc2.interfaces.NodeData & improc2.interfaces.ProcessedData
    
    properties
        
        blobSumIntensities
        blobMedianIntensities
        blobModeIntensities
        blobStdevOfIntensities
        totalBlobSumIntensity
        totalBlobMedianIntensity
        nuclearNotBlobSumIntensities
        nuclearNotBlobMedianIntensities
        nuclearNotBlobModeIntensities
        proportionPixelsAboveThreshold
        needsUpdate = true %Update flag
        %         img
    end
    
    properties (Constant = true)
        
%         dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', 'improc2.dataNodes.ChannelStackContainer'};
        dependencyClassNames = {'improc2.blobAnalyzer.blobCollectionOneChannel', 'improc2.dataNodes.ChannelStackContainer'};
        dependencyDescriptions = {'blob node','intensity channel'};
    end
    
    
    properties
        %         objectHandle %The handle to the image object being view
        dataNodeLabel %Label for blob Node
        parentNodeLabels %Label for spot Data parent Nodes
    end
    
    
    
    methods
        function pDataAfterProcessing = run(p, blobNode, intensityChannel)
            [p.blobSumIntensities, p.blobMedianIntensities, p.blobModeIntensities, p.blobStdevOfIntensities, p.proportionPixelsAboveThreshold] = getIntensityOfBlobs(p, blobNode, intensityChannel);
            [p.nuclearNotBlobSumIntensities, p.nuclearNotBlobMedianIntensities, p.nuclearNotBlobModeIntensities] = getIntensityOfNuclearNotBlobs(p, blobNode, intensityChannel);
            p.totalBlobSumIntensity = sum(p.blobSumIntensities, 'all');
            p.totalBlobMedianIntensity = median(p.blobMedianIntensities, 'all');
            
            pDataAfterProcessing = p;
        end
        
        function p = blobIntensityOneChannel(varargin)
            ip = inputParser;
            ip.addParameter('channelsToProcess', []); %intensity channel
            ip.addParameter('nodeLabel', []);
            ip.parse(varargin{:});
            channels = ip.Results.channelsToProcess;
            p.dataNodeLabel = ip.Results.nodeLabel;
        end
        
        function [sumIntensity, medianIntensity, modeIntensity, blobStdevOfIntensities, percentPixelsAboveThreshold] = getIntensityOfBlobs(p, blobNode, intensityChannel)
            blobMasks = blobNode.blobMasks;
            img = intensityChannel.croppedImage;
            img = max(img, [], 3);
            topPixelValue = max(img);
            blobsConnComp = bwconncomp(blobMasks);
            blobs = blobsConnComp.PixelIdxList;
            sumIntensity = [];
            medianIntensity = [];
            modeIntensity = [];
            blobStdevOfIntensities = [];
            percentPixelsAboveThreshold = [];
            [nuclearNotBlobSumIntensity, nuclearNotBlobMedianIntensity, nuclearNotBlobModeIntensity] = getIntensityOfNuclearNotBlobs(p, blobNode, intensityChannel);
            for i = 1:length(blobs)
                individualBlobIds = blobs{i};
                [individualBlobMaskRow, individualBlobMaskColumn] = ind2sub(size(img), individualBlobIds);
                individualBlobMask = zeros(size(img));
                individualBlobMask(individualBlobMaskRow, individualBlobMaskColumn) = 1;
                sumIntensity = [sumIntensity, sum(double(img).*individualBlobMask, 'all')];
                onlyInMask = double(img).*individualBlobMask;
                onlyInMask(onlyInMask==0) = NaN;
                medianIntensity = [medianIntensity, nanmedian(onlyInMask, 'all')];
                modeIntensity = [modeIntensity, mode(onlyInMask, 'all')];
                blobStdevOfIntensities = [blobStdevOfIntensities, std(onlyInMask, 1, 'all', 'omitnan')];
                
                threshold = (topPixelValue-nuclearNotBlobMedianIntensity)*0.5;
                numPixelsAboveThreshold = sum((onlyInMask-nuclearNotBlobMedianIntensity)>=threshold, 'all', 'omitnan');
                totalPixels = sum(onlyInMask>=0, 'all', 'omitnan');
                percentPixelsAboveThreshold = [percentPixelsAboveThreshold, numPixelsAboveThreshold./totalPixels];
            end
            
        end
        
        function [nuclearNotBlobSumIntensity, nuclearNotBlobMedianIntensity, nuclearNotBlobModeIntensity] = getIntensityOfNuclearNotBlobs(p, blobNode, intensityChannel)
           nuclearNotBlobMasks = blobNode.notBlobNucleusMask;
           img = intensityChannel.croppedImage; 
           nuclearNotBlobSumIntensity = sum(double(img).*nuclearNotBlobMasks, 'all');
           onlyInMask = double(img).*nuclearNotBlobMasks;
           onlyInMask(onlyInMask==0) = NaN;
           nuclearNotBlobMedianIntensity = nanmedian(onlyInMask, 'all');
           nuclearNotBlobModeIntensity = mode(onlyInMask, 'all');
            
        end
        

        
        function flagAsReviewed(p)
            data = p.objectHandle.getData({p.dataNodeLabel});
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function out = isvalid(p)
            out = true;
        end
    end
    
end
