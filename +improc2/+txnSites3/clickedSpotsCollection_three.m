classdef clickedSpotsCollection_three < ...
        improc2.txnSites3.interfaces.manualSpotCollection & improc2.interfaces.NodeData
    
    properties
        ClickedXs %holds the X positions of the actual spot clicked by the user
        ClickedYs %holds the y positions of the actual spot clicked by the user
        clickedPointID
        X
        Y
        Z
        Intensity %The amplitude of the Guassian that is fit to the spot located at (ExonXs, ExonYs)
        parentNodeName
        pointID
        needsUpdate = true %Update flag
        ColocDistances %holds the pdist2 values for all the exons and introns near the clicked points
    end

    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', 'improc2.interfaces.FittedSpotsContainer', 'improc2.interfaces.FittedSpotsContainer'};
%         channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
%         [dependencyClassNames{1:length(channels)}] = deal('improc2.interfaces.FittedSpotsContainer');
        dependencyDescriptions = {'all channels'};
    end

     
    properties
        objectHandle %The handle to the image object being view
        dataNodeLabel %Label for TxnSite Node
        parentNodeLabels %Label for Fitted Data parent Nodes
    end
    
    methods
        %Create Object
        function p = clickedSpotsCollection_three(objectHandle, varargin)
            ip = inputParser;
            ip.addParameter('nodeName', 'ManuallyClickedSpots', @ischar);
            ip.addParameter('channels', improc2.thresholdGUI.findRNAChannels(objectHandle));
            ip.parse(varargin{:});
            p.objectHandle = objectHandle;
            p.dataNodeLabel = [ip.Results.nodeName];
%             channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
            channels = ip.Results.channels;            
            p.parentNodeLabels = {};
            for i = channels
                p.parentNodeLabels = [p.parentNodeLabels, strcat(i, ':Fitted')];
            end
        end
        
        function out = isvalid(p)
            out = true;
        end
        %Add a transcription site to the Image Object Data. When the user
        %clicks on the GUI where they believe there is a Transcription
        %site, this function takes the x,y coord of the click, finds the
        %nearest exon and intron spot, checks if they colocalize and adds
        %the intensity value of the exon spot
        function addClickedSpot(p, x, y)
            data = p.objectHandle.getData(p.dataNodeLabel);
            %Store the coordinates of the clicked point
            data.ClickedXs = [data.ClickedXs; x];
            data.ClickedYs = [data.ClickedYs; y];
            data.clickedPointID = [data.clickedPointID; length(data.ClickedXs)];
            
            for i = 1:length(p.parentNodeLabels)
                SpotData = p.objectHandle.getData((p.parentNodeLabels{i})).getFittedSpots;

                fittedXs = [];
                fittedYs = [];
                fittedZs = [];
                intensities = [];
                if (numel(SpotData) > 0)
                    for j = 1:numel(SpotData)
                        fittedXs = [fittedXs, SpotData(j).xCenter];
                        fittedYs = [fittedYs, SpotData(j).yCenter];
                        fittedZs = [fittedZs, SpotData(j).zPlane];
                        intensities = [intensities, SpotData(j).amplitude];
                    end
                    %Find closest exon spot the where the user clicked
                    nn = knnsearch([fittedXs', fittedYs'], [x,y]);
                    data.X = [data.X; fittedXs(nn)];
                    data.Y = [data.Y; fittedYs(nn)];
                    data.Z = [data.Z; fittedZs(nn)];
                    data.Intensity = [data.Intensity, intensities(nn)];
                    data.parentNodeName = [data.parentNodeName; (p.parentNodeLabels(i))];
                    data.pointID = [data.pointID; repmat(length(data.ClickedXs), 1)];
                else
                   sprintf('No spots!')
                end
%                 data.pointID = [data.pointID repmat(length(data.X), 3)];
            
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
            
        end

        function [X, Y] = getClickedSpotCoordinates(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            X = data.ClickedXs;
            Y = data.ClickedYs;
        end
        
        function [pointID] = getPointIDs(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            pointID = data.pointID;
        end
        
        function [X, Y, Z, parentNodeName] = getNearbySpotCoordinates(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            X = data.X;
            Y = data.Y;
            Z = data.Z;
            parentNodeName = data.parentNodeName;
        end
        
%         function [Xs, Ys] = getOtherCoordsToDisplayOnInit(p)
%             % This function is used to get data other than txn sites that
%             % needs to be displayed on GUI initialization. We need to mark
%             % the called introns for IntronExon txn sites so this function
%             % returns the coordinates of all the called introns. Edit if
%             % some other data needs to be displayed on init.
%             IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
%             Xs = [];
%             Ys = [];
%             %there may be not intron spots so check
%             if (numel(IntronSpotData) > 0)
%                 for i = 1:numel(IntronSpotData)
%                     Xs = [Xs, IntronSpotData(i).xCenter];
%                     Ys = [Ys, IntronSpotData(i).yCenter];
%                 end
%             end
%         end
%         
        function Ints = getNearbyIntensities(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Ints = data.Intensity;
        end
        
        
        
        function deleteLastClickedSpot(p)            
            data = p.objectHandle.getData(p.dataNodeLabel);
                if length(data.ClickedXs) < 2
                    data.ClickedXs = [];
                    data.ClickedYs = [];
                    data.clickedPointID = [];
                    data.X = [];
                    data.Y = [];
                    data.Z = [];
                    data.Intensity = [];
                    data.parentNodeName = [];
                    data.pointID = [];
                else
                    pointID = data.clickedPointID(end);
                    data.ClickedXs = data.ClickedXs(1:(end-1));
                    data.ClickedYs = data.ClickedYs(1:(end-1));
                    data.clickedPointID = data.clickedPointID(1:(end-1));
                    idx = ismember(data.pointID,pointID);
                    data.X(idx) = [];
                    data.Y(idx) = [];
                    data.Z(idx) = [];
                    data.Intensity(idx) = [];
                    data.parentNodeName(idx) = [];
                    data.pointID(idx) = [];
                end
                fprintf('A total of %s', sprintf([num2str(numel(data.ClickedXs)) ' clicked spots in image!\n']));
            p.objectHandle.setData(data, p.dataNodeLabel);

        end
        
        function deleteClickedSpot(p,x)

            objectHandle = p.objectHandle;

            [rnaChannels] = improc2.thresholdGUI.findRNAChannels(objectHandle);

            rnaChannelSwitch = dentist.utils.ChannelSwitchCoordinator(rnaChannels);
            
            for k = 1:length(rnaChannels)
                rnaChannelSwitch.setChannelName(rnaChannels{k})
                idx = ismember(p.objectHandle.getData(p.dataNodeLabel).ClickedXs,x);
                pointID = p.objectHandle.getData(p.dataNodeLabel).clickedPointID(idx);
                nearbyidx = ismember(p.objectHandle.getData(p.dataNodeLabel).pointID,pointID);
               
                rnaProcessorDataHolder = improc2.utils.ProcessorDataHolder(...
                objectHandle, rnaChannelSwitch, 'clickedSpotsCollection_three');

                rnaProcessorDataHolder.processorData.pointID(nearbyidx) = [];
%                 rnaProcessorDataHolder.processorData.pointID = isvalid(rnaProcessorDataHolder.processorData.pointID);
                rnaProcessorDataHolder.processorData.X(nearbyidx) = [];
%                 rnaProcessorDataHolder.processorData.X = isvalid(rnaProcessorDataHolder.processorData.X);
                rnaProcessorDataHolder.processorData.Y(nearbyidx) = [];
%                 rnaProcessorDataHolder.processorData.Y = isvalid(rnaProcessorDataHolder.processorData.Y);
                rnaProcessorDataHolder.processorData.Z(nearbyidx) = [];
%                 rnaProcessorDataHolder.processorData.Z = isvalid(rnaProcessorDataHolder.processorData.Z);
                rnaProcessorDataHolder.processorData.parentNodeName(nearbyidx) = [];
                rnaProcessorDataHolder.processorData.ClickedXs(idx) = [];
                rnaProcessorDataHolder.processorData.ClickedYs(idx) = [];
                rnaProcessorDataHolder.processorData.Intensity(nearbyidx) = [];
                
            end
            
            
        end
        
  
        
        function moveClickedSpot(p, pointID, xCoord, yCoord)
            
            data = p.objectHandle.getData(p.dataNodeLabel);
            
            idx = ismember(data.clickedPointID,pointID);
            data.ClickedXs(idx) = [xCoord];
            data.ClickedYs(idx) = [yCoord];
            idy = ismember(data.pointID,pointID);
            for i = 1:length(p.parentNodeLabels)
                SpotData = p.objectHandle.getData((p.parentNodeLabels{i})).getFittedSpots;
                
                fittedXs = [];
                fittedYs = [];
                fittedZs = [];
                intensities = [];
                if (numel(SpotData) > 0)
                    for j = 1:numel(SpotData)
                        fittedXs = [fittedXs, SpotData(j).xCenter];
                        fittedYs = [fittedYs, SpotData(j).yCenter];
                        fittedZs = [fittedZs, SpotData(j).zPlane];
                        intensities = [intensities, SpotData(j).amplitude];
                    end
                    
                    nn = knnsearch([fittedXs', fittedYs'], [xCoord,yCoord]);
                    data.X(idy) = fittedXs(nn);
                    data.Y(idy) = fittedYs(nn);
                    data.Z(idy) = fittedZs(nn);
                    data.Intensity(idy) = intensities(nn);
                    data.parentNodeName(idy) = p.parentNodeLabels(i);
%                     data.pointID(idy) = pointID;
                else
                   fprintf('No spots in %s', p.parentNodeLabels(i),'!\n')
                end
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
            
            
        end
        
%         function clearAllTranscriptionSites(p)
%             data = p.objectHandle.getData(p.dataNodeLabel);
%             data.ExonXs = [];
%             data.ExonYs = [];
%             data.ExonZs = [];
%             data.IntronXs = [];
%             data.IntronYs = [];
%             data.IntronZs = [];
%             data.IntronIntensity = [];
%             data.Intensity = [];
%             data.ColocXs =  [];
%             data.ColocYs =  [];
%             data.ColocIntensity = [];
%             data.ColocDistances = [];
%             p.objectHandle.setData(data, p.dataNodeLabel);
%         end
        
        function flagAsReviewed(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end

