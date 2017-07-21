classdef IntronOrExonTranscriptionSitesCollection < ...
        improc2.txnSites2.interfaces.TranscriptionSitesCollection
    %Object that interacts with the IntronExon TxnSite Data Nodes
    properties
        objectHandle %The handle to the image object being view
        dataNodeLabel %Label for TxnSite Node
        parentNodeLabels %Label for Fitted Data parent Nodes
    end
    
    methods
        %Create Object
        function p = IntronOrExonTranscriptionSitesCollection(objectHandle, intronChannel, exonChannel)
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
            % Initiate housekeeping variables
            thereIsAnExonNearClick = false;
            thereIsAnIntronNearClick = false;
            data = p.objectHandle.getData(p.dataNodeLabel);
            
            %Store the coordinates of the clicked point
            data.ClickedXs = [data.ClickedXs; x];
            data.ClickedYs = [data.ClickedYs; y];
            ExonSpotData = p.objectHandle.getData(p.parentNodeLabels{1}).getFittedSpots;
            ExonfittedXs = [];
            ExonfittedYs = [];
            ExonfittedZs = [];
            intensities = [];
            
            if numel(ExonSpotData) > 0
                for i = 1:numel(ExonSpotData)
                    ExonfittedXs = [ExonfittedXs, ExonSpotData(i).xCenter];
                    ExonfittedYs = [ExonfittedYs, ExonSpotData(i).yCenter];
                    ExonfittedZs = [ExonfittedZs, ExonSpotData(i).zPlane];
                    intensities = [intensities, ExonSpotData(i).amplitude];
                end
                %Find closest exon spot the where the user clicked
                [closestExonToClick, exonDistanceToClick] = knnsearch([ExonfittedXs', ExonfittedYs'], [x,y]);
                data.ExonXs = [data.ExonXs; ExonfittedXs(closestExonToClick)];
                data.ExonYs = [data.ExonYs; ExonfittedYs(closestExonToClick)];
                data.ExonZs = [data.ExonZs; ExonfittedZs(closestExonToClick)];
                data.Intensity = [data.Intensity, intensities(closestExonToClick)];
                thereIsAnExonNearClick = true;
            else
                fprintf('%s', sprintf('No exon spots in object\n'))
            end
            
            IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
            IntronfittedXs = [];
            IntronfittedYs = [];
            IntronfittedZs = [];
            AllIntronIntensities = [];
            %there may be not intron spots so check
            if (numel(IntronSpotData) > 0)
                for i = 1:numel(IntronSpotData)
                    IntronfittedXs = [IntronfittedXs, IntronSpotData(i).xCenter];
                    IntronfittedYs = [IntronfittedYs, IntronSpotData(i).yCenter];
                    IntronfittedZs = [IntronfittedZs, IntronSpotData(i).zPlane];
                    AllIntronIntensities = [AllIntronIntensities, IntronSpotData(i).amplitude];
                end
                %Find closest intron spot if there are any
                [closestIntronToClick, intronDistanceToClick] = knnsearch([IntronfittedXs', IntronfittedYs'], [x,y]);
                data.IntronXs = [data.IntronXs; IntronfittedXs(closestIntronToClick)];
                data.IntronYs = [data.IntronYs; IntronfittedYs(closestIntronToClick)];
                data.IntronZs = [data.IntronZs; IntronfittedZs(closestIntronToClick)];
                data.IntronIntensity = [data.IntronIntensity, AllIntronIntensities(closestIntronToClick)];
                thereIsAnIntronNearClick = true;
            else 
                fprintf('%s', sprintf('No intron spots in object\n'))
            end
            
            if thereIsAnExonNearClick && thereIsAnIntronNearClick
                distanceBetweenPoints = pdist2([data.ExonXs(end), data.ExonYs(end)], [data.IntronXs(end), data.IntronYs(end)]);
                if distanceBetweenPoints < 3
                    data.ColocDistances = [data.ColocDistances, distanceBetweenPoints];
                    
                    colocalized_Index = data.ColocDistances <= 3;
                    fprintf('%s', sprintf('The Exon and Intron closest to clicked point colocalize, And have been added as a Txn Site!\n'));
                    fprintf('A total of %s', sprintf([num2str(numel(data.ColocDistances)) ' txn sites added in this object\n']));
                    fprintf('%s', sprintf([num2str(sum(colocalized_Index)) ' out of ' num2str(sum(~isnan(data.ColocDistances))) ' IntronExon txnsites Colocalized\n']));
                    fprintf('-----\n')
                else
                    data.ColocDistances = [data.ColocDistances, distanceBetweenPoints];
                    
                    colocalized_Index = data.ColocDistances <= 3;
                    fprintf(2, sprintf('The Exon and Intron closest to clicked point do not colocalize, but have been added as Txn Sites!\n'));
                    fprintf('A total of %s', sprintf([num2str(numel(data.ColocDistances)) ' txn sites added in this object\n']));
                    fprintf('%s', sprintf([num2str(sum(colocalized_Index)) ' out of ' num2str(sum(~isnan(data.ColocDistances))) ' IntronExon txnsites Colocalized\n']));
                    fprintf('-----\n')
                end
            elseif ~thereIsAnExonNearClick && ~thereIsAnIntronNearClick
                fprintf(2 , sprintf('There are no spots in this image!\n'));
                fprintf('-----\n')
            elseif ~thereIsAnExonNearClick && thereIsAnIntronNearClick
                data.ColocDistances = [data.ColocDistances, nan];
                
                fprintf('%s', sprintf('There are no Exons in this image. The Intron closest to the clicked point has been added as a txn site.\n'));
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocDistances)) ' txn sites added in this object\n']));
                fprintf('-----\n')
            elseif thereIsAnExonNearClick && ~thereIsAnIntronNearClick
                data.ColocDistances = [data.ColocDistances, nan];
                
                fprintf('%s', sprintf('There are no Introns in this image. The Exon closest to the clicked point has been added as a txn site.\n'));
                fprintf('A total of %s', sprintf([num2str(numel(data.ColocDistances)) ' txn sites added in this object\n']));
                fprintf('-----\n')
            end
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
%         function addTranscriptionSite(p, x, y)
%             thereIsAnExon = false;
%             thereIsAnIntron = false;
%             
%             distanceToCheckFromClick = 3; %This is the euclidian distance
%             %from the click within which we check for the presence of
%             %fitted exon and intron spots
%             distanceForColoc = 3;
%             
%             data = p.objectHandle.getData(p.dataNodeLabel);
%             
%             % Find the closest intron and exon spot to the clicked point
%             % and within a radius of 3 pixels. Store the X, Y and intensity
%             % of the spot(s).
%             % Depending on whether there is an intron, exon, or both,
%             % assign the kind of txn site. 
%             % If it is an intronexon txn site, check for colocalization, 
%             % calculate and add the coloc distances and coloc x, y and
%             % intensity (this part needs to be taken out? It duplicates the
%             % exon x and y).
%             
%             %Store the coordinates of the clicked point
%             data.ClickedXs = [data.ClickedXs; x];
%             data.ClickedYs = [data.ClickedYs; y];
%             ExonSpotData = p.objectHandle.getData(p.parentNodeLabels{1}).getFittedSpots;
%             ExonfittedXs = [];
%             ExonfittedYs = [];
%             intensities = [];
%             %there may not be exon spots so check
%             if numel(ExonSpotData) > 0
%                 for i = 1:numel(ExonSpotData)
%                     ExonfittedXs = [ExonfittedXs, ExonSpotData(i).xCenter];
%                     ExonfittedYs = [ExonfittedYs, ExonSpotData(i).yCenter];
%                     intensities = [intensities, ExonSpotData(i).amplitude];
%                 end
%                 %Find closest exon spot the where the user clicked
%                 [nn, ndist] = knnsearch([ExonfittedXs', ExonfittedYs'], [x,y]);
%                 if ndist <= distanceToCheckFromClick
%                     data.ExonXs = [data.ExonXs; ExonfittedXs(nn)];
%                     data.ExonYs = [data.ExonYs; ExonfittedYs(nn)];
%                     data.Intensity = [data.Intensity, intensities(nn)];
%                     thereIsAnExon = true;
%                 else 
%                     fprintf('%s', sprintf('No exon spots within %d pixels of click\n', distanceToCheckFromClick))
%                 end
%             else
%                 fprintf('%s', sprintf('No exon spots in object\n'))
%             end
%             
%             IntronSpotData = p.objectHandle.getData(p.parentNodeLabels{2}).getFittedSpots;
%             IntronfittedXs = [];
%             IntronfittedYs = [];
%             AllIntronIntensities = [];
%             %there may be not intron spots so check
%             if (numel(IntronSpotData) > 0)
%                 for i = 1:numel(IntronSpotData)
%                     IntronfittedXs = [IntronfittedXs, IntronSpotData(i).xCenter];
%                     IntronfittedYs = [IntronfittedYs, IntronSpotData(i).yCenter];
%                     AllIntronIntensities = [AllIntronIntensities, IntronSpotData(i).amplitude];
%                 end
%                 %Find closest intron spot if there are any
%                 [mm, mdist] = knnsearch([IntronfittedXs', IntronfittedYs'], [x,y]);
%                 if mdist <= distanceToCheckFromClick
%                     data.IntronXs = [data.IntronXs; IntronfittedXs(mm)];
%                     data.IntronYs = [data.IntronYs; IntronfittedYs(mm)];
%                     data.IntronIntensity = [data.IntronIntensity, AllIntronIntensities(mm)];
%                     thereIsAnIntron = true;
%                 else 
%                     fprintf('%s', sprintf('No intron spots within %d pixels of click\n', distanceToCheckFromClick))
%                 end
%             else 
%                 fprintf('%s', sprintf('No intron spots in object\n'))
%             end
%                 
%             if (thereIsAnExon && thereIsAnIntron)
%                 fprintf('%s', sprintf('This is an IntronExon txn site.\n'))
%                 
%                 %Find the pairwise distance between each exon and intron
%                 ColocDistances = pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]);
%                 data.ColocDistances = diag(ColocDistances);
%                 [minDistances, minIndex] = min(ColocDistances');
%                 %if the distance is fewer than 3 pixels, they
%                 %colocalized. This may need editing especially without a
%                 %chromatic shift
%                 colocalized_Index = minDistances < 3;
%                 data.ColocXs =  data.ExonXs;
%                 data.ColocYs =  data.ExonYs;
%                 data.ColocIntensity = data.Intensity';
%                 data.TypeTxnSite{end+1} = {'intronexon'};
%                 
%                 %Check to see if the Exon and Intron identified during the
%                 %last click colocalize
%                 isClickColoc = pdist2([ExonfittedXs(nn), ExonfittedYs(nn)], [IntronfittedXs(mm), IntronfittedYs(mm)]) < distanceForColoc;
%                 
%                 if ~isClickColoc
%                     fprintf(2, 'Intron and Exon not colocalized! But have been added as a txn site.\n')
%                 else
%                     fprintf('Intron and Exon colocalized! And have been added as a txn site.\n')
%                 end
%                 fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' txn sites added in this object\n']));
%                 fprintf('%s', sprintf([num2str(numel(data.ColocXs(colocalized_Index))) ' out of ' num2str(sum(~isnan(data.ColocXs))) ' IntronExon txnsites Colocalized\n']));
%                 fprintf('-----\n')
%             elseif (thereIsAnExon && ~thereIsAnIntron)
%                 fprintf('%s', sprintf('This is an Exon only txn site.\n'))
%                 data.IntronXs = [data.IntronXs; nan];
%                 data.IntronYs = [data.IntronYs; nan];
%                 data.IntronIntensity = [data.IntronIntensity, nan];
%                 data.ColocXs = [data.ColocXs; nan];
%                 data.ColocYs = [data.ColocYs; nan];
%                 data.ColocIntensity = [data.ColocIntensity; nan];
%                 data.ColocDistances = diag(pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]));
%                 data.TypeTxnSite{end+1} = {'exononly'};                
%                 fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' txn sites added in this object\n']));
%                 fprintf('-----\n')
%             elseif (~thereIsAnExon && thereIsAnIntron)
%                 fprintf('%s', sprintf('This is an Intron only txn site.\n'))
%                 data.ExonXs = [data.ExonXs; nan];
%                 data.ExonYs = [data.ExonYs; nan];
%                 data.Intensity = [data.Intensity, nan];
%                 data.ColocXs = [data.ColocXs; nan];
%                 data.ColocYs = [data.ColocYs; nan];
%                 data.ColocIntensity = [data.ColocIntensity; nan];
%                 data.ColocDistances = diag(pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]));
%                 data.TypeTxnSite{end+1} = {'intrononly'};
%                 
%                 fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' txn sites added in this object\n']));
%                 fprintf('-----\n')
%             else
%                 fprintf('%s', sprintf('No fitted spots within %d pixels of click!\n', distanceToCheckFromClick))
%                 fprintf('A total of %s', sprintf([num2str(numel(data.ColocXs)) ' txn sites added in this object\n']));
%                 fprintf('-----\n')
%             end
%             p.objectHandle.setData(data, p.dataNodeLabel);
%             
%         end
        %return the exon X and Ys
        function [Xs, Ys] = getTranscriptionSiteXYCoords(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Xs = data.ExonXs;
            Ys = data.ExonYs;
        end
        
        %return the intron X and Ys
        function [Xs, Ys] = getTranscriptionSiteIntronXYCoords(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            Xs = data.IntronXs;
            Ys = data.IntronYs;
        end
        
        %return the txn site (exon and intron) Z planes
        function [ExonZs, IntronZs] = getTranscriptionSiteZPlanes(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            ExonZs = data.ExonZs;
            IntronZs = data.IntronZs;
        end
        
        function [Xs, Ys] = getOtherCoordsToDisplayOnInit(p)
            % This function is used to get data other than txn sites that
            % needs to be displayed on GUI initialization. We need to mark
            % the called introns for IntronExon txn sites so this function
            % returns the coordinates of all the called introns. Edit if
            % some other data needs to be displayed on init.
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
            if length(data.IntronXs) < 2
                data.IntronXs = [];
                data.IntronYs = [];
                data.IntronZs = [];
                data.IntronIntensity = [];
            else
                data.IntronXs = data.IntronXs(1:(end-1));
                data.IntronYs = data.IntronYs(1:(end-1));
                data.IntronZs = data.IntronZs(1:(end-1));
                data.IntronIntensity = data.IntronIntensity(1:(end-1));
            end
            if length(data.ExonXs) < 2
                data.ExonXs = [];
                data.ExonYs = [];
                data.ExonZs = [];
                data.ClickedXs = [];
                data.ClickedYs = [];
                data.Intensity = [];
                data.ColocIntensity = [];
                data.ColocDistances = [];
                data.TypeTxnSite = {};
            else
                data.ExonXs = data.ExonXs(1:(end-1));
                data.ExonYs = data.ExonYs(1:(end-1));
                data.ExonZs = data.ExonZs(1:(end-1));
                data.ClickedXs = data.ClickedXs(1:(end-1));
                data.ClickedYs = data.ClickedYs(1:(end-1));
                data.Intensity = data.Intensity(1:(end-1));
                data.ColocIntensity = data.ColocIntensity(1:(end-1));
                data.ColocDistances = data.ColocDistances(1:(end-1));
                data.TypeTxnSite = data.TypeTxnSite(1:end-1);
            end
            %The index for Colocalzed spots has no reference to the
            %uncolocized spot, so to properly adjust, recalculate
            %colocalization
%             distance = pdist2([data.ExonXs, data.ExonYs], [data.IntronXs, data.IntronYs]);
%             [minDistances, minIndex] = min(distance');
%             colocalized_Index = find(minDistances < 3);
%             data.ColocXs =  data.ExonXs;
%             data.ColocYs =  data.ExonYs;
%             data.ColocIntensity = data.Intensity';
            fprintf('%s', sprintf('The last txn site has been deleted.\n'))
            fprintf('A total of %s', sprintf([num2str(numel(data.ExonXs)) ' txn sites added so far.\n']));
            fprintf('-----\n')
            
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
        
        function clearAllTranscriptionSites(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.ExonXs = [];
            data.ExonYs = [];
            data.ExonZs = [];
            data.IntronXs = [];
            data.IntronYs = [];
            data.IntronZs = [];
            data.IntronIntensity = [];
            data.Intensity = [];
            data.ColocXs =  [];
            data.ColocYs =  [];
            data.ColocIntensity = [];
            data.ColocDistances = [];
            data.TypeTxnSite = {};
            p.objectHandle.setData(data, p.dataNodeLabel);
            fprintf('%s', sprintf('All the txn sites for this object have been successfully deleted!\n'))
            fprintf('-----\n')
        end
        
        function flagAsReviewed(p)
            data = p.objectHandle.getData(p.dataNodeLabel);
            data.needsUpdate = false;
            p.objectHandle.setData(data, p.dataNodeLabel);
        end
    end
    
end

