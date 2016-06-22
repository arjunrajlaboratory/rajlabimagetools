classdef IntronExonTranscriptionSitesCollection < ...
        improc2.txnSites2.interfaces.TranscriptionSitesCollection
    %Object that interacts with the IntronExon TxnSite Data Nodes
    properties
        objectHandle %The handle to the image object being view
        dataNodeLabel %Label for TxnSite Node
        parentNodeLabels %Label for Fitted Data parent Nodes
    end
    
    methods
        %Create Object
        function p = IntronExonTranscriptionSitesCollection(objectHandle, intronChannel, exonChannel)
            p.objectHandle = objectHandle;
            p.dataNodeLabel = [exonChannel, intronChannel, ':TxnSites'];
            p.parentNodeLabels = {[exonChannel ':Fitted'], [intronChannel ':Fitted']};
        end
        %Add a transcription site to the Image Object Data. When the user
        %clicks on the GUI where they believe there is a Transcription
        %site, this function takes the x,y coord of the click, finds the
        %nearest exon and intron spot, checks if they colocalize and adds
        %the intensity value of the exon spot
        function addTranscriptionSite(p, x, y)
            data = p.objectHandle.getData(p.dataNodeLabel);
            %Store the coordinates of the clicked point
            data.ClickedXs = [data.ClickedXs; x];
            data.ClickedYs = [data.ClickedYs; y];
            ExonSpotData = p.objectHandle.getData(p.parentNodeLabels{1}).getFittedSpots;
            ExonfittedXs = [];
            ExonfittedYs = [];
            intensities = [];
            for i = 1:numel(ExonSpotData)
                ExonfittedXs = [ExonfittedXs, ExonSpotData(i).xCenter];
                ExonfittedYs = [ExonfittedYs, ExonSpotData(i).yCenter];
                intensities = [intensities, ExonSpotData(i).amplitude];
            end
            %Find closest exon spot the where the user clicked
            nn = knnsearch([ExonfittedXs', ExonfittedYs'], [x,y]);
            data.ExonXs = [data.ExonXs; ExonfittedXs(nn)];
            data.ExonYs = [data.ExonYs; ExonfittedYs(nn)];
            data.Intensity = [data.Intensity, intensities(nn)];
            
            IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
            IntronfittedXs = [];
            IntronfittedYs = [];
            %there may be not intron spots so check
            if (numel(IntronSpotData) > 0)
                for i = 1:numel(IntronSpotData)
                    IntronfittedXs = [IntronfittedXs, IntronSpotData(i).xCenter];
                    IntronfittedYs = [IntronfittedYs, IntronSpotData(i).yCenter];
                end
                %Find closest intron spot if there are any
                mm = knnsearch([IntronfittedXs', IntronfittedYs'], [x,y]);
                data.IntronXs = [data.IntronXs; IntronfittedXs(mm)];
                data.IntronYs = [data.IntronYs; IntronfittedYs(mm)];
                %Find the pairwise distance between each exon and intron
                distance = pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]);
                [minDistances, minIndex] = min(distance');
                %if the distance is fewer than 3 pixels, they
                %colocalized. This may need editing especially without a
                %chromatic shift
                colocalized_Index = find(minDistances < 3);
                data.ColocXs =  data.ExonXs;
                data.ColocYs =  data.ExonYs;
                data.ColocIntensity = data.Intensity;
                
                %Check to see if the Exon and Intron identified during the
                %last click colocalize
                isClickColoc = pdist2([ExonfittedXs(nn), ExonfittedYs(nn)], [IntronfittedXs(mm), IntronfittedYs(mm)]) < 3;
                
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' spots added\n']));
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs(colocalized_Index))) ' spots Colocalized\n']));
                if ~isClickColoc
                    fprintf(2, 'This spot is Not Colocalized!\n')
                    fprintf('-----\n')
                else
                    fprintf('This spot is Colocalized!\n')
                    fprintf('-----\n')
                end
            else
                fprintf('%s', sprintf('No intron spots in object\n'))
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
            
        end
        %return the exon X and Ys
        function [Xs, Ys] = getTranscriptionSiteXYCoords(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Xs = data.ExonXs;
            Ys = data.ExonYs;
        end
        
        function [Xs, Ys] = getIntronXYCoords(p)
            IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
            Xs = [];
            Ys = [];
            %there may be not intron spots so check
            if (numel(IntronSpotData) > 0)
                for i = 1:numel(IntronSpotData)
                    Xs = [Xs, IntronSpotData(i).xCenter];
                    Ys = [Ys, IntronSpotData(i).yCenter];
                end
            end
        end
        
        function Ints = getTranscriptionSiteInts(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Ints = data.Ints;
        end
        %Delete the most recently added transcription site
        function deleteLastTranscriptionSite(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            if (length(data.ExonXs) ~= length(data.IntronXs))
                fprintf('%s', sprintf(['There was a mismatch between number of'...
                    ' Exon and Intron spots. \nThis happens when the intron '...
                    'thershold produces no intron spots. \nThe last Exon '...
                    'spot will be deleted, but consider clearing all '...
                    'spots and repicking\n']))
                if length(data.ExonXs) < 2
                    data.ExonXs = [];
                    data.ExonYs = [];
                    data.ClickedXs = [];
                    data.ClickedYs = [];
                    data.Intensity = [];
                else
                    data.ExonXs = data.ExonXs(1:(end-1));
                    data.ExonYs = data.ExonYs(1:(end-1));
                    data.ClickedXs = data.ClickedXs(1:(end-1));
                    data.ClickedYs = data.ClickedYs(1:(end-1));
                    data.Intensity = data.Intensity(1:(end-1));
                end
                
            else
                if length(data.IntronXs) < 2
                    data.IntronXs = [];
                    data.IntronYs = [];
                else
                    data.IntronXs = data.IntronXs(1:(end-1));
                    data.IntronYs = data.IntronYs(1:(end-1));
                end
                if length(data.ExonXs) < 2
                    data.ExonXs = [];
                    data.ExonYs = [];
                    data.ClickedXs = [];
                    data.ClickedYs = [];
                    data.Intensity = [];
                else
                    data.ExonXs = data.ExonXs(1:(end-1));
                    data.ExonYs = data.ExonYs(1:(end-1));
                    data.ClickedXs = data.ClickedXs(1:(end-1));
                    data.ClickedYs = data.ClickedYs(1:(end-1));
                    data.Intensity = data.Intensity(1:(end-1));
                end
                %The index for Colocalzed spots has no reference to the
                %uncolocized spot, so to properly adjust, recalculate
                %colocalization
                distance = pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]);
                [minDistances, minIndex] = min(distance');
                colocalized_Index = find(minDistances < 3);
                data.ColocXs =  data.ExonXs;
                data.ColocYs =  data.ExonYs;
                data.ColocIntensity = data.Intensity;
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' spots added \n']));
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs(colocalized_Index))) ' spots colocalized \n']));
            end
            
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function clearAllTranscriptionSites(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.ExonXs = [];
            data.ExonYs = [];
            data.IntronXs = [];
            data.IntronYs = [];
            data.Intensity = [];
            data.ColocXs =  [];
            data.ColocYs =  [];
            data.ColocIntensity = [];
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function flagAsReviewed(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end

