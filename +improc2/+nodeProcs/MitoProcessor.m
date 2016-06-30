%% SNPColocalizer Class
% This object performs colocalization for the SNP-FISH Assay. It also has a
% couple of built-in utility functions that makes checking on results easy,
% such as viewing a bursting cell.
%
% As far as property names, I use the following nomenclature (ish). In
% retrospect, I probably should have made a struct array instead.
%
%   _1 corresponds to guide
%   _2 corresponds to snpA
%   _3 corresponds to snpB

% Paul Ginart, 2013

classdef MitoProcessor < improc2.interfaces.ProcessedData
    
    
    properties
        needsUpdate = true
    end
    properties (Constant = true)
        dependencyClassNames = {...
            'improc2.interfaces.FittedSpotsContainer',...
            'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'guide', 'snpA'};
    end
    
    
    properties (SetAccess = private)
        initialDistance; % Distance for colocalization in the first pass
        finalDistance;  % Distance for colcalization in the second pass
        zDeform; % scale factor for Z for colocalization
        % The idea is to convert to pixel distances, but then reduce the importance of z spacing tremendously.
        % We do that because we aren't fitting z, so
        % the z position information is relatively bad
        % (especially compared with x and y).
        
        shiftFlag; %true if performing a shift correction
        
        guideData;
        
        % Alternative:
        % snpMap
        % snpMap.guide
        % snpMap.snpA.name
        % snpMap.snpA.channelName
        
        snpMap % Structure that specifices the SNP mapping. Has two fields.
        %    ex: names - {'guide', 'snpA', 'snpB'}
        %        channels - {'gfp', 'tmr', 'cy'}
        %    In this case, gfp is the guide probe, and the tmr
        %    channel probe is snpA and the cy channel probe is
        %    snpB
        
        data %Struct with a dataset subfield for each of the channels used
        %Guide Probe Properties.
        %Labels
        % (n x 1) nominal catagoral vector with 3 possible labels
        %   'undetec' - no colocalization with guide
        %   snpMap.channels(2) - single colocalization with guide
        %   '3-color' - colocalization with guide and
        %   other SNP probe
        %SNP B Properties
        
        medDiff_12    % median shift correction between the guide and SNP A
        medDiff_13    % median shift correction between the guide and SNP B
        
        
        guide_data %dataSetObjects that contain the above information in coherent form
        snpA_data
        snpB_data
        
        pixelShift 
    end
    
    methods
        
        function p = run(p, guideFittedSpotsHolder, ...
                snpAFittedSpotsHolder)
            
            guideSpots = getFittedSpots(guideFittedSpotsHolder);
            snpASpots = getFittedSpots(snpAFittedSpotsHolder);
            snpBSpots = getFittedSpots(snpAFittedSpotsHolder);
            
            numGuide = numel(guideSpots);
            numsnpA = numel(snpASpots);
            numsnpB = numel(snpBSpots);
            
            guide_zCoordinates = arrayfun(@(x) x* p.zDeform, [guideSpots.zPlane]);
            snpA_zCoordinates = arrayfun(@(x) x* p.zDeform, [snpASpots.zPlane]);
            snpB_zCoordinates = arrayfun(@(x) x* p.zDeform, [snpBSpots.zPlane]);
            
            guidePositions = [[guideSpots.xCenter]' + p.pixelShift, [guideSpots.yCenter]' + p.pixelShift, guide_zCoordinates'];
            snpAPositions = [[snpASpots.xCenter]', [snpASpots.yCenter]', snpA_zCoordinates'];
            snpBPositions = [[snpBSpots.xCenter]', [snpBSpots.yCenter]', snpB_zCoordinates'];
                 
            [pairsA, shiftsA] = colocalizePositions(p, guidePositions,snpAPositions);
            [pairsB, shiftsB] = colocalizePositions(p, guidePositions,snpBPositions);

            idx_guide = zeros(numGuide, 1);
            Labels = cell(numGuide,1);     %Vector that idenitifies the label of each guide probe
            
            idx_snpA = zeros(numsnpA, 1);
            LabelsA = cell(numsnpA,1);
            
            idx_snpB = zeros(numsnpB, 1);
            LabelsB = cell(numsnpB,1);
            
            idx_coGuideSnpA = zeros(numGuide, 1);
            idx_coGuideSnpB = zeros(numGuide, 1);
            
            positions_coGuideSnpA = zeros(numGuide, 3);
            positions_coGuideSnpB = zeros(numGuide, 3);
            
            amplitude_coGuideSnpA = zeros(numGuide, 1);
            amplitude_coGuideSnpB = zeros(numGuide, 1);
            
            sigma_coGuideSnpA = zeros(numGuide, 1);
            sigma_coGuideSnpB = zeros(numGuide, 1);
            
            
            if ~isempty(pairsA)
              idx_guide(pairsA(:,1)) = idx_guide(pairsA(:,1)) + 1;
              Labels(pairsA(:,1)) = p.snpMap.names(1);
              
              idx_snpA(pairsA(:,2)) = idx_snpA(pairsA(:,2)) + 1;
              LabelsA(pairsA(:,2)) = p.snpMap.names(1);
              
              idx_coGuideSnpA(pairsA(:,1)) = pairsA(:,2);
              positions_coGuideSnpA(pairsA(:,1),:) = snpAPositions(pairsA(:,2),:);
              
              amplitudeSNPA = [snpASpots.amplitude]';
              sigmaSNPA = [snpASpots.sigma]';
              
              amplitude_coGuideSnpA(pairsA(:,1)) = amplitudeSNPA(pairsA(:,2));
              sigma_coGuideSnpA(pairsA(:,1)) = sigmaSNPA(pairsA(:,2));
              
            end
            
            if ~isempty(pairsB)
                idx_guide(pairsB(:,1)) = idx_guide(pairsB(:,1)) + 1;
                Labels(pairsB(:,1)) = p.snpMap.names(2);
                
                idx_snpB(pairsB(:,2)) = idx_snpB(pairsB(:,2)) + 1;
                LabelsB(pairsB(:,2)) = p.snpMap.names(2);
                
                idx_coGuideSnpB(pairsB(:,1)) = pairsB(:,2);
                
                positions_coGuideSnpB(pairsB(:,1),:) = snpBPositions(pairsB(:,2),:);
              
                amplitudeSNPB = [snpBSpots.amplitude]';
                sigmaSNPB = [snpBSpots.sigma]';
              
                amplitude_coGuideSnpB(pairsB(:,1)) = amplitudeSNPB(pairsB(:,2));
                sigma_coGuideSnpB(pairsB(:,1)) = sigmaSNPB(pairsB(:,2));
            end
            
            Labels(idx_guide == 0) = cellstr('undetec');
            Labels(idx_guide == 2) = cellstr('3-color'); %order matters here
            levels = {p.snpMap.names{1}, p.snpMap.names{2}, 'undetec', '3-color'};
            labels = nominal();
            labels = addlevels(labels, levels);
            
            LabelsA(idx_snpA == 0) = cellstr('undetec');
            levelsA = {p.snpMap.names{2}, 'undetec', '3-color'};
            labelsA = nominal();
            labelsA = addlevels(labelsA, levelsA);
            
            LabelsB(idx_snpB == 0) = cellstr('undetec');
            levelsB = {p.snpMap.names{2}, 'undetec', '3-color'};
            labelsB = nominal();
            labelsB = addlevels(labelsB, levelsB);
            
            
            p.guideData = dataset();  
            p.data.(p.snpMap.channels{1}).ID = [1:numGuide]';
            p.data.(p.snpMap.channels{1}).position =  guidePositions;dat2 = dataset();
            p.data.(p.snpMap.channels{1}).amplitude = [guideSpots.amplitude]';
            p.data.(p.snpMap.channels{1}).sigma = [guideSpots.sigma]';
            p.data.(p.snpMap.channels{1}).labels = vertcat(labels, nominal(Labels));
            
            p.data.(p.snpMap.channels{1}).snpA_ID = idx_coGuideSnpA; 
            p.data.(p.snpMap.channels{1}).snpA_positions = positions_coGuideSnpA;
            p.data.(p.snpMap.channels{1}).snpA_amplitude = amplitude_coGuideSnpA;
            p.data.(p.snpMap.channels{1}).snpA_sigma = sigma_coGuideSnpA;
            
          
            p.data.(p.snpMap.channels{1}).snpB_ID = idx_coGuideSnpB;
            p.data.(p.snpMap.channels{1}).snpB_positions = positions_coGuideSnpB;
            p.data.(p.snpMap.channels{1}).snpB_amplitude = amplitude_coGuideSnpB;
            p.data.(p.snpMap.channels{1}).snpB_sigma = sigma_coGuideSnpB;
            
            if sum(idx_guide == 2)
                three_color_spots_ID = find(idx_guide == 2);
                
                snp_3color_pairs_indexA = find(ismember(pairsA(:,1), three_color_spots_ID));
                snp_3color_IDs_A = pairsA(snp_3color_pairs_indexA,2);
                LabelsA(snp_3color_IDs_A) = cellstr('3-color');
                
                snp_3color_pairs_indexB = find(ismember(pairsB(:,1), three_color_spots_ID));
                snp_3color_IDs_B = pairsB(snp_3color_pairs_indexB,2);
                LabelsB(snp_3color_IDs_B) = cellstr('3-color');
            end

            p.data.(p.snpMap.channels{2}).ID = [1:numsnpA]';
            p.data.(p.snpMap.channels{2}).position = snpAPositions;
            p.data.(p.snpMap.channels{2}).amplitude = [snpASpots.amplitude]';
            p.data.(p.snpMap.channels{2}).sigma = [snpASpots.sigma]';
            p.data.(p.snpMap.channels{2}).labels = vertcat(labelsA, nominal(LabelsA));
            
            p.data.(p.snpMap.channels{2}).ID = [1:numsnpB]';
            p.data.(p.snpMap.channels{2}).position = snpBPositions;
            p.data.(p.snpMap.channels{2}).amplitude = [snpBSpots.amplitude]';
            p.data.(p.snpMap.channels{2}).sigma = [snpBSpots.sigma]';
            p.data.(p.snpMap.channels{2}).labels = vertcat(labelsB, nominal(LabelsB));
            
            
            
%             
%             if sum(idx_coGuideSnpA) > 0
%                 p.data.(p.snpMap.channels{1}).snpA_positions(logical(idx_coGuideSnpA)) = ...
%                     p.data.(p.snpMap.channels{2}).position(logical(idx_coGuideSnpA));
%             end
%             
            
            
            %fprintf('Currently run does nothing\n');
        end
        
        function [pairs,  shifts] = colocalizePositions(p, guidePositions, snpPositions)
            
            if and(~isempty(guidePositions), ~isempty(snpPositions))
            pairwiseDist = pdist2(guidePositions, snpPositions);
            
            [minGuideDistances, minSnpIndex] = min(pairwiseDist');
            
            % find guides and SNPs that have snp within < initialDistance
            guide_colocalized_Index = find(minGuideDistances < p.initialDistance)';
            snp_colocalized_Index = minSnpIndex(guide_colocalized_Index)';
            
            % chromatic shift for each one of these
            % try to make dimensions involved more explicit
            totalShift = guidePositions(guide_colocalized_Index,:) ...
                - snpPositions(snp_colocalized_Index,:);
            medianShift = median(totalShift);
            
            
            snpPositions_shifted = bsxfun(@plus, snpPositions, medianShift);
            pairwiseDist = pdist2(guidePositions, snpPositions_shifted);
            
            [minGuideDistances, minSnpIndex] = min(pairwiseDist');
            
            % find guides and SNPs that have snp within < initialDistance
            guide_colocalized_Index = find(minGuideDistances < p.finalDistance)';
            snp_colocalized_Index = minSnpIndex(guide_colocalized_Index)';
            
            % move out of loop if want to keep shiftflag= false option.
            pairs = [guide_colocalized_Index, snp_colocalized_Index];
            
            shifts = zeros(length(guidePositions), 3);
            shifts(guide_colocalized_Index,:) = guidePositions(guide_colocalized_Index,:) ...
                - snpPositions(snp_colocalized_Index,:);
            
            else
               
                pairs = [];
                shifts = [];
            end
            
            
            
        end
    end
    
    methods
        function p = MitoProcessor(snpMap, varargin)
            p.snpMap = snpMap;
            parser = inputParser;
            
            parser.addOptional('shiftFlag',true, @islogical); 
            
            % rename to: colocolization radius for chromatic shift
            % calculation
            parser.addOptional('initialDistance',2.5,@isnumeric);
            
            % coloc. radius for final colocolization.
            parser.addOptional('finalDistance',1.5,@isnumeric);
            
            % Factor to shrink the z distance into pixels.
            % includes a factor to make z distance differences less
            % important
            parser.addOptional('zDeform',(0.35/.13 * 1/20),@isnumeric);
            
            parser.addOptional('pixelShift',0,@isnumeric);
            
            parser.parse(varargin{:});
            
            p.shiftFlag = parser.Results.shiftFlag;
            p.initialDistance = parser.Results.initialDistance;
            p.finalDistance = parser.Results.finalDistance;
            p.zDeform = parser.Results.zDeform;
            p.pixelShift = parser.Results.pixelShift;
            
        end
        
        % THE OLD PROCESSING FUNCTION
        function p = oldRunMethod(p,inObj)
            %Load in data from gaussian post-processor and place into dataset
            pos_transformed = struct();

            
            
            % EXTRACT METHOD-----
            for i = 1:numel(p.snpMap.channels)
                if isfield(inObj.channels.(p.snpMap.channels{i}).metadata,'gaussFitPostProc')
                    
                   % change ' to (:)
                    x = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.xp';  %Draws data from post-processed fit
                    y = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.yp';
                    z = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.zp';
                    
                    numSpots(i) = length(x);
                    
                    p.data.(p.snpMap.channels{i}) = dataset();
                    p.data.(p.snpMap.channels{i}).ID = [1:numSpots(i)]';
                    p.data.(p.snpMap.channels{i}).position = [x, y, z];
                    p.data.(p.snpMap.channels{i}).amplitude = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.amp';
                    p.data.(p.snpMap.channels{i}).sigma = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.sig';
                    
                    pos_transformed.(p.snpMap.channels{i}) = [x, y, z * p.zDeform]; %temporarily store z-deformed coordinates for localization
                    
                    if isempty(pos_transformed.(p.snpMap.channels{i}))
                        pos_transformed.(p.snpMap.channels{i}) = zeros(0,3); %set data equal to zero so that things work later
                    end
                    
                else

                    % Should be an error. Won't be necessary in newest version. 
                    fprintf('Have to run gaussFitPostProc first\n');
                end
            end
            
            
            
            guidePositions = pos_transformed.(p.snpMap.channels{1}); %for clarity
            pairs = cell(2,1); %Cell array to store IDs of pairs
            
            shift{1} = zeros(numSpots(1),3);
            shift{2} = zeros(numSpots(1),3);
            
            
            % Extract method : colocolize to guide
            for i = 2:3
                %Finds the minimum pairwise distance between the guide and
                %snp probe and filters it the initial cutoff radius
                snpPositions = pos_transformed.(p.snpMap.channels{i});
                pairwiseDist = pdist2(guidePositions, snpPositions);
                
                % for each guide get closest snp
                [minGuideDistances, snp_ID] = min(pairwiseDist');
                
                % find guides and SNPs that have snp within < initialDistance
                guide_colocalized_ID = find(minGuideDistances < p.initialDistance)';
                snp_colocalized_ID = snp_ID(guide_colocalized_ID)';
                
                % chromatic shift for each one of these
                % try to make dimensions involved more explicit
                totalShift = guidePositions(guide_colocalized_ID,:) ...
                        - snpPositions(snp_colocalized_ID,:);
                medianShift = median(totalShift);
                
                % flag decides whether to go on to next stage of
                % colocolization
                
                % It looks like this is always assumed true, to get pairs
                % and shift.
                % rename shfitFlag.
                if p.shiftFlag
                    %apply median shift
                    snpPositions_shifted = bsxfun(@plus, snpPositions, medianShift);
                    %repeat colocalization
                    pairwiseDist = pdist2(guidePositions, snpPositions_shifted);
                    [minGuideDistances, snp_ID] = min(pairwiseDist');
                    % uses finalDistance
                    guide_colocalized_ID = find(minGuideDistances < p.finalDistance)';
                    snp_colocalized_ID = snp_ID(guide_colocalized_ID)';
                    
                    
                    % move out of loop if want to keep shiftflag= false option.
                    pairs{i-1} = [guide_colocalized_ID, snp_colocalized_ID];
                    shift{i-1}(guide_colocalized_ID,:) = guidePositions(guide_colocalized_ID,:) ...
                        - snpPositions(snp_colocalized_ID,:);
                end
            end
            %   ------

            %Create Labels for guide probe
            
            % idx_guide -> number of colocolized SNPs.
            idx_guide = zeros(numSpots(1), 1);
            
            % should be more explicit.
            %0 for undetected SNP, 1 for detected SNP, 2 for two-color co-localization
            idx_guide(pairs{1}(:,1)) = idx_guide(pairs{1}(:,1)) + 1;
            idx_guide(pairs{2}(:,1)) = idx_guide(pairs{2}(:,1)) + 1;
            
            Labels = cell(numSpots(1),1);     %Vector that idenitifies the label of each guide probe
            Labels(idx_guide == 0) = cellstr('undetec');
            Labels(pairs{1}(:,1)) = p.snpMap.names(2);
            Labels(pairs{2}(:,1)) = p.snpMap.names(3);
            Labels(idx_guide == 2) = cellstr('3-color'); %order matters here
            
            levels = {p.snpMap.names{2}, p.snpMap.names{3}, 'undetec', '3-color'};
            labels = nominal();
            labels = addlevels(labels, levels);
            p.data.(p.snpMap.channels{1}).labels = vertcat(labels, nominal(Labels));
            
            %   %%  %%
            % CONTINUE HERE
            %   %%  %%
            
%             levelsToAdd_idx = ~ismember(levels, getlevels(p.data.(p.snpMap.channels{1}).labels));
%             if any(levelsToAdd_idx)
%             p.data.(p.snpMap.channels{1}).labels = addlevels(p.data.(p.snpMap.channels{1}).labels, ...
%                 cellstr(levels(levelsToAdd_idx)));
%             end
            
            snpA_neighbors = zeros(numSpots(1),1);
            snpB_neighbors = zeros(numSpots(1),1);
            
            snpA_amplitude = zeros(numSpots(1),1);
            snpB_amplitude = zeros(numSpots(1),1);
            
            snpA_neighbors(pairs{1}(:,1)) = pairs{1}(:,2);
            snpB_neighbors(pairs{2}(:,1)) = pairs{2}(:,2);
            
            snpA_amplitude(pairs{1}(:,1)) = p.data.(p.snpMap.channels{2}).amplitude(pairs{1}(:,2));
            snpB_amplitude(pairs{2}(:,1)) = p.data.(p.snpMap.channels{3}).amplitude(pairs{2}(:,2));

            neighborSet = dataset({snpA_neighbors, [p.snpMap.channels{2}, '_neighbors']}, ...
                {shift{1}, [p.snpMap.channels{2}, '_shift']}, ...
                {snpA_amplitude, [p.snpMap.channels{2}, '_amplitude']}, ...
                {snpB_neighbors, [p.snpMap.channels{3}, '_neighbors']}, ...
                {shift{2}, [p.snpMap.channels{3}, '_shift']}, ...
                {snpB_amplitude, [p.snpMap.channels{3}, '_amplitude']});
            
            p.data.(p.snpMap.channels{1}) = horzcat(p.data.(p.snpMap.channels{1}), neighborSet);
            
            
            %Get Labels for SNPS
            three_color_spots_ID = find(idx_guide == 2);
            for i = 2:3
                Labels = []; %Clear variable
                
                snp_3color_pairs_index = find(ismember(pairs{i-1}(:,1), three_color_spots_ID));
                snp_3color_IDs = pairs{i-1}(snp_3color_pairs_index,2);
                
                Labels = cellstr(repmat('undetec', numSpots(i),1));
                Labels(pairs{i-1}(:,2)) = p.snpMap.names(i);
                Labels(snp_3color_IDs) = cellstr('3-color');
                
                labels = nominal();
                labels = addlevels(labels, levels);
                p.data.(p.snpMap.channels{i}).labels = vertcat(labels, nominal(Labels));
                
%                 p.data.(p.snpMap.channels{i}).labels = nominal(Labels);
%                 levelsToAdd_idx = ~ismember(levels, getlevels(p.data.(p.snpMap.channels{i}).labels));
%                 
%                 if any(levelsToAdd_idx)
%                 p.data.(p.snpMap.channels{i}).labels = addlevels(p.data.(p.snpMap.channels{i}).labels, ...
%                 cellstr(levels(levelsToAdd_idx)));
%                 end
            
                
                p.data.(p.snpMap.channels{i}).guide_neighbors = zeros(numSpots(i),1);
                p.data.(p.snpMap.channels{i}).guide_neighbors(pairs{i-1}(:,2)) = pairs{i-1}(:,1);
            end

            
        end
        
        function showSNP(p,inObj,whichLabel)
            % Plots all spots on max merge of guide probe channel and
            % single SNP channel as labeled by whichLabel
            if p.isProcessed % If the processor has already been run
                
                idx_snpMap_vector = find(strcmp(p.snpMap.names, whichLabel));
                snpChannel = p.snpMap.channels{idx_snpMap_vector};
                
                img = inObj.channelStk(p.snpMap.channels{1});
                
                shift = ['medDiff_1', num2str(idx_snpMap_vector)]; %Set which shift we are colocalizing with respect to
                posSNP = ['pos_', num2str(idx_snpMap_vector)];
                
                guidePositions = p.pos_1;
                snpPositions = p.(posSNP);
                shifts = p.(shift);
                snpPositions = bsxfun(@plus, snpPositions, shifts);
                
                imgmax = max(img,[],3);  %MAX MERGE
                
                hold off;
                imgmax = imadjust(imgmax,[0.3 0.5],[]);
                imshow(imgmax,[]);  %Plot image
                
                hold on;
                plot(guidePositions(:,2),guidePositions(:,1),'go');  % First the ref channel in green
                plot(snpPositions(:,2), snpPositions(:,1), 'co');  % other channel in cyan
                plot(guidePositions(p.labels_1 == whichLabel,2), guidePositions(p.labels_1 == whichLabel,1),'mo','markersize',10); %Plot the co_localized spots
                
                hold off;
            else
                fprintf('Colocalization analysis not run yet.\n');
            end;
        end;
        
        function showResults(p, inObj)
            
            if p.isProcessed % If the processor has already been run
                img = inObj.channelStk(p.snpMap.channels{1}); %Get image in guide channel
                guidePositions = p.pos_1;
                
                snpA_IDs = p.neighborIDs_1(:,1);
                snpB_IDs = p.neighborIDs_1(:,2);
                
                snpAidx = snpA_IDs(snpA_IDs > 0);
                snpBidx = snpB_IDs(snpB_IDs > 0);
                
                snpAPositions = p.pos_2;
                snpBPositions = p.pos_3;
                
                snpAPositions = snpAPositions(snpAidx,:);
                snpBPositions = snpBPositions(snpBidx,:);
                
                snpAPositions = bsxfun(@plus, snpAPositions, p.medDiff_12);  %Add in the median shift
                snpBPositions = bsxfun(@plus, snpBPositions, p.medDiff_13);
                
                imgmax = max(img,[],3);  %MAX MERGE
                
                hold off;
                spotsPic = figure;
                
                imshow(imgmax,[]);  %Plot image
                
                %
                hold on;
                plot(guidePositions(:,2),guidePositions(:,1),'yo');  % First the ref channel in green
                plot(guidePositions(p.labels_1 == p.snpMap.names{2},2), guidePositions(p.labels_1 == p.snpMap.names{2},1),'co','markersize',10); %Plot the co_localized spots
                plot(guidePositions(p.labels_1 == p.snpMap.names{3},2), guidePositions(p.labels_1 == p.snpMap.names{3},1),'mo','markersize',10); %Plot the co_localized spots
                
                color3_idx =  p.labels_1 == '3-color';
                
                intensities2 = [p.intensity_2(p.neighborIDs_1(color3_idx, 1)), p.intensity_2(p.neighborIDs_1(p.labels_1 == p.snpMap.names{2},1))];
                intensities3 = [p.intensity_3(p.neighborIDs_1(color3_idx, 2)), p.intensity_3(p.neighborIDs_1(p.labels_1 == p.snpMap.names{3},2))];
                
                [n xout] = hist(intensities2, 500);
                xout(end) = max(intensities2);
                percentile2 = cumsum(n./length(intensities2));
                [n2 xout2] = hist(intensities3, 500);
                xout2(end) = max(intensities3);
                percentile3 = cumsum(n2./length(intensities3));
                
                snpIntensity = [p.intensity_2(p.neighborIDs_1(color3_idx, 1))', p.intensity_3(p.neighborIDs_1(color3_idx, 2))'] %Intensity of spots
                snpPercentiles = [];
                for i = 1:length(snpIntensity)
                    snpPercentiles = [snpPercentiles; percentile2(find(xout >= snpIntensity(i,1), 1,'first')), percentile3(find(xout2 >= snpIntensity(i,2), 1,'first'))];
                    color3_2(i) = percentile2(find(xout >= snpIntensity(i,1), 1,'first')) > percentile3(find(xout2 >= snpIntensity(i,2), 1,'first'));
                end
                
                color3guides = guidePositions(color3_idx,:);
                
                plot(color3guides(color3_2, 2), color3guides(color3_2, 1), 'co', 'markersize',10)
                plot(color3guides(~color3_2, 2), color3guides(~color3_2, 1), 'mo', 'markersize',10)
                legend(p.snpMap.names)
                
                name = inObj(1).channels.gfp.filename;
                name = name(4:6);
                
                print(spotsPic, '-dtiff', ['spots', name]);
                
                hold off;
                
                %                 intensityPic = figure;
                %                 scatter(snpIntensity(:,1), snpIntensity(:,2));
                %                 title('Intensity Scatter');
                %                 xlabel([p.snpMap.names{2}, ' pixel intensity']);
                %                 ylabel([p.snpMap.names{3}, ' pixel intenisty']);
                %                 print(intensityPic, '-djpeg', ['intensity', name]);
                
                
                %                 percentilePic = figure;
                %                 scatter(snpPercentiles(:,1), snpPercentiles(:,2));
                %                 title('Percentile Scatter');
                %                 xlabel(p.snpMap.names{2});
                %                 ylabel(p.snpMap.names{3});
                %                 print(percentilePic, '-djpeg', ['percentile', name]);
                %                 close all
                %
                
            else
                fprintf('Colocalization analysis not run yet.\n');
            end;
            
        end
        
    end
    
end






