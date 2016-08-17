%% TwoChannelColocalizer Class
% This class performs colocalization for any two channels of interest after 
% gaussian fitting has been performed on the required spots. 
%
% It requires exactly two Gaussian-fitted channels for input.
% 
% Colocalization is performed with Euclidian distance in x- and y-
% dimensions, with an allowed range of z-planes defined by the zAllow 
% property. By default, zAllow = 3 planes either up or down (+3, -3).
% 
% Colocalization is performed in two stages to correct for chromatic
% abberation in dye properties. Note that this step may confound results if
% you are colocalizing two channels with very highly spot counts.
% 
% Ian Mellis, 2016, based on SNPColocalizer.m

classdef TwoChannelColocalizer < improc2.interfaces.ProcessedData
    
    
    properties
        needsUpdate = true
    end
    properties (Constant = true)
        dependencyClassNames = {...
            'improc2.interfaces.FittedSpotsContainer',...
            'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'chan1', 'chan2'};
    end
    
    
    properties (SetAccess = private)
        initialDistance;    % Distance for colocalization in the first pass
        finalDistance;      % Distance for colcalization in the second pass
        
        zAllow;              % Maximum number of z-planes difference in
                             % either direction allowed for colocalization 
                             
        
        shiftFlag; %true if performing a shift correction 
        
        xyPixelDistance;  % xy pixel resolution (standard is 0.13 microns)
        zStepSize;  % z step size in journal (standard is 0.35 microns)
        
        pixelShift; % number of pixels to shift each channel in x- and y-
                    % directions prior to colocalization. Used for checking
                    % colocalization rate due to random chance.
        
        idMap % Structure that specifices the channel mapping. Has two 
        %    fields.
        %    ex: names - {'odds', 'evens'}
        %        channels - {'tmr', 'cy'}
        %    In this case, tmr is the set of odds and cy is the set of
        %    evens.
        
        data %Struct with a dataset subfield for each of the channels used
        %Guide Probe Properties.
        %Labels
        % (n x 1) nominal catagoral vector with 2 possible labels
        %   'undetec' - no colocalization with guide
        %   idMap.names(other channel) - colocalization with other channel
        
    end
    
    methods
        
        function p = run(p, chan1FittedSpotsHolder, ...
                chan2FittedSpotsHolder) %, snpBFittedSpotsHolder)
            
            chan1Spots = getFittedSpots(chan1FittedSpotsHolder);
            chan2Spots = getFittedSpots(chan2FittedSpotsHolder);
%             snpBSpots = getFittedSpots(snpBFittedSpotsHolder);
            
            numChan1 = numel(chan1Spots);
            numChan2 = numel(chan2Spots);
%             numsnpB = numel(snpBSpots);
            
            chan1Positions = [[chan1Spots.xCenter]' + p.pixelShift, [chan1Spots.yCenter]'+ p.pixelShift, [chan1Spots.zPlane]'];
            chan2Positions = [[chan2Spots.xCenter]', [chan2Spots.yCenter]', [chan2Spots.zPlane]'];
%             snpBPositions = [[snpBSpots.xCenter]', [snpBSpots.yCenter]', [snpBSpots.zPlane]'];
            
            if size(chan1Positions, 2) < 3
                chan1Positions = zeros(0,3);
            end
            
            if isempty(p.zAllow)
                p.zAllow = 3;
                disp(['Empty zAllow. Set to default value = ', num2str(p.zAllow)])
            end
                        
            [pairs1, shifts1] = colocalizePositions(p, chan1Positions, chan2Positions);
%             [pairsB, shiftsB] = colocalizePositions(p, chan1Positions,snpBPositions);

            idx_chan1 = zeros(numChan1, 1);
            Labels = cell(numChan1,1);     %Vector that idenitifies the label of each guide probe
            
            idx_chan2 = zeros(numChan2, 1);
            Labels12 = cell(numChan2,1);
            
%             idx_snpB = zeros(numsnpB, 1);
%             LabelsB = cell(numsnpB,1);
            
            idx_coChan1Chan2 = zeros(numChan1, 1);
%             idx_coGuideSnpB = zeros(numChan1, 1);
            
            positions_coChan1Chan2 = zeros(numChan1, 3);
%             positions_coGuideSnpB = zeros(numChan1, 3);
            
            amplitude_coChan1Chan2 = zeros(numChan1, 1);
%             amplitude_coGuideSnpB = zeros(numChan1, 1);
            
            sigma_coChan1Chan2 = zeros(numChan1, 1);
%             sigma_coGuideSnpB = zeros(numChan1, 1);            
            
            if ~isempty(pairs1)
              idx_chan1(pairs1(:,1)) = idx_chan1(pairs1(:,1)) + 1;
              Labels(pairs1(:,1)) = p.idMap.names(2); %check index
              
              idx_chan2(pairs1(:,2)) = idx_chan2(pairs1(:,2)) + 1;
              Labels12(pairs1(:,2)) = p.idMap.names(2); % check index
              
              idx_coChan1Chan2(pairs1(:,1)) = pairs1(:,2);
              positions_coChan1Chan2(pairs1(:,1),:) = chan2Positions(pairs1(:,2),:);
              
              amplitudeChan2 = [chan2Spots.amplitude]';
              sigmaChan12 = [chan2Spots.sigma]';
              
              amplitude_coChan1Chan2(pairs1(:,1)) = amplitudeChan2(pairs1(:,2));
              sigma_coChan1Chan2(pairs1(:,1)) = sigmaChan12(pairs1(:,2));
              
            end
            
%             if ~isempty(pairsB)
%                 idx_chan1(pairsB(:,1)) = idx_chan1(pairsB(:,1)) + 1;
%                 Labels(pairsB(:,1)) = p.snpMap.names(3);
%                 
%                 idx_snpB(pairsB(:,2)) = idx_snpB(pairsB(:,2)) + 1;
%                 LabelsB(pairsB(:,2)) = p.snpMap.names(3);
%                 
%                 idx_coGuideSnpB(pairsB(:,1)) = pairsB(:,2);
%                 
%                 positions_coGuideSnpB(pairsB(:,1),:) = snpBPositions(pairsB(:,2),:);
%               
%                 amplitudeSNPB = [snpBSpots.amplitude]';
%                 sigmaSNPB = [snpBSpots.sigma]';
%               
%                 amplitude_coGuideSnpB(pairsB(:,1)) = amplitudeSNPB(pairsB(:,2));
%                 sigma_coGuideSnpB(pairsB(:,1)) = sigmaSNPB(pairsB(:,2));
%             end
            
            Labels(idx_chan1 == 0) = cellstr('undetec');
            Labels(idx_chan1 == 2) = cellstr('3-color'); %order matters here
            levels = {p.idMap.names{2}, ... % p.snpMap.names{3}, 
                'undetec'}; %, '3-color'}; % CHECK
            labels = nominal();
            labels = addlevels(labels, levels);
            
            Labels12(idx_chan2 == 0) = cellstr('undetec');
            levels1 = {p.idMap.names{2}, 'undetec'}; %, '3-color'};
            labels1 = nominal();
            labels1 = addlevels(labels1, levels1);
            
%             LabelsB(idx_snpB == 0) = cellstr('undetec');
%             levelsB = {p.snpMap.names{3}, 'undetec', '3-color'};
%             labelsB = nominal();
%             labelsB = addlevels(labelsB, levelsB);
            
            p.data.(p.idMap.channels{1}).ID = [1:numChan1]';
            p.data.(p.idMap.channels{1}).position =  chan1Positions;
            p.data.(p.idMap.channels{1}).amplitude = [chan1Spots.amplitude]';
            p.data.(p.idMap.channels{1}).sigma = [chan1Spots.sigma]';
            p.data.(p.idMap.channels{1}).labels = vertcat(labels, nominal(Labels));
            
            p.data.(p.idMap.channels{1}).chan2_ID = idx_coChan1Chan2;
            p.data.(p.idMap.channels{1}).chan2_positions = positions_coChan1Chan2;
            p.data.(p.idMap.channels{1}).chan2_amplitude = amplitude_coChan1Chan2;
            p.data.(p.idMap.channels{1}).chan2_sigma = sigma_coChan1Chan2;
            
          
%             p.data.(p.snpMap.channels{1}).snpB_ID = idx_coGuideSnpB;
%             p.data.(p.snpMap.channels{1}).snpB_positions = positions_coGuideSnpB;
%             p.data.(p.snpMap.channels{1}).snpB_amplitude = amplitude_coGuideSnpB;
%             p.data.(p.snpMap.channels{1}).snpB_sigma = sigma_coGuideSnpB;
            
%             if sum(idx_chan1 == 2)
%                 three_color_spots_ID = find(idx_chan1 == 2);
%                 
%                 snp_3color_pairs_indexA = find(ismember(pairs1(:,1), three_color_spots_ID));
%                 snp_3color_IDs_A = pairs1(snp_3color_pairs_indexA,2);
%                 Labels12(snp_3color_IDs_A) = cellstr('3-color');
%                 
%                 snp_3color_pairs_indexB = find(ismember(pairsB(:,1), three_color_spots_ID));
%                 snp_3color_IDs_B = pairsB(snp_3color_pairs_indexB,2);
%                 LabelsB(snp_3color_IDs_B) = cellstr('3-color');
%             end

            p.data.(p.idMap.channels{2}).ID = [1:numChan2]';
            p.data.(p.idMap.channels{2}).position = chan2Positions;
            p.data.(p.idMap.channels{2}).amplitude = [chan2Spots.amplitude]';
            p.data.(p.idMap.channels{2}).sigma = [chan2Spots.sigma]';
            p.data.(p.idMap.channels{2}).labels = vertcat(labels1, nominal(Labels12));
            
%             p.data.(p.idMap.channels{3}).ID = [1:numsnpB]';
%             p.data.(p.idMap.channels{3}).position = snpBPositions;
%             p.data.(p.idMap.channels{3}).amplitude = [snpBSpots.amplitude]';
%             p.data.(p.idMap.channels{3}).sigma = [snpBSpots.sigma]';
%             p.data.(p.idMap.channels{3}).labels = vertcat(labelsB, nominal(LabelsB));
            
            
        end
        
        function [pairs,  shifts] = colocalizePositions(p, chan1Positions, chan2Positions)
            
            if and(~isempty(chan1Positions), ~isempty(chan2Positions))
%             pairwiseDist = pdist2(guidePositions, snpPositions);
              pairwiseDist = colocDist(chan1Positions, chan2Positions, p.zAllow);
            
            sizeTest = size(pairwiseDist);
%             disp('TwoChannelColocalizer pairwiseDist:')
%             pairwiseDist
            [minChan1Distances, minChan2Index] = min(pairwiseDist', [], 1);
                      
            % find guides and SNPs that have snp within < initialDistance
            chan1_colocalized_Index = find(minChan1Distances < p.initialDistance)';
            chan2_colocalized_Index = minChan2Index(chan1_colocalized_Index)';
            
            if sum(minChan1Distances < p.initialDistance) == 1
                
                if minChan1Distances(chan1_colocalized_Index) < p.finalDistance
                    
                    pairs = [chan1_colocalized_Index, chan2_colocalized_Index];
                    chan1ID = 1:size(chan1Positions, 1);
                    chan2PosID = 1:size(chan2Positions, 1);
                    
                else
                    
                    pairs = [];
                    
                end
                
            else
            
                % chromatic shift for each one of these
                totalShift = chan1Positions(chan1_colocalized_Index,:) ...
                    - chan2Positions(chan2_colocalized_Index,:);
                medianShift = median(totalShift, 1);
                
                
                chan2Positions_shifted = bsxfun(@plus, chan2Positions, medianShift);
                %             pairwiseDist = pdist2(guidePositions, snpPositions_shifted);
                pairwiseDist = colocDist(chan1Positions, chan2Positions_shifted, p.zAllow);
                
                chan1ID = 1:size(chan1Positions, 1);
                chan2PosID = 1:size(chan2Positions_shifted, 1);
                
                pairs  = colocalizePosRecursive(p, chan1Positions, chan2Positions_shifted, ...
                    p.finalDistance, chan1ID, chan2PosID);
                
            end
            
            if ~isempty(pairs)
                shifts = zeros(length(chan1Positions), 3);
                chan1_FINALcolocalized_Idx = ismember(chan1ID, pairs(:,1));
                chan2_FINALcolocalized_Idx = ismember(chan2PosID, pairs(:,2));
                shifts(chan1_FINALcolocalized_Idx,:) = chan1Positions(chan1_FINALcolocalized_Idx,:) ...
                    - chan2Positions(chan2_FINALcolocalized_Idx,:);
            else
                pairs = [];
                shifts = [];
            end
            
            else
               
                pairs = [];
                shifts = [];
            end
  
        end
        function   pairs = colocalizePosRecursive(p, chan1Positions, ...
                chan2Positions_shifted, finalDist, chan1ID, chan2PosID)
            
            pairs = [];
            pairwiseDist = colocDist(chan1Positions, chan2Positions_shifted, p.zAllow);
            [minChan1Distances, minChan2Index] = min(pairwiseDist', [], 1);
            
            chan1_colocalized_Index = find(minChan1Distances < finalDist)';
            
            if isempty(chan1_colocalized_Index)
                return
            else
                chan2_colocalized_Index = minChan2Index(chan1_colocalized_Index)';
                
                currChan1ID = chan1ID(chan1_colocalized_Index);
                currChan2ID = chan2PosID(chan2_colocalized_Index);
                
                if length(unique(currChan2ID)) ~= length(currChan2ID)
                    [~,ia,ic] = unique(currChan2ID);
                    currChan2_Idxes = 1:length(currChan2ID);
                    chan2_doubleColoc_Idxes = ~ismember(currChan2_Idxes, ia);
                    chan2_doubleColoc_IDs = currChan2ID(chan2_doubleColoc_Idxes);
                    chan2_properColoc_Idxes = ismember(currChan2_Idxes, ia);
                    chan2_properColoc_IDs = currChan2ID(chan2_properColoc_Idxes);
                    
                    chan1ID_properColoc = currChan1ID(chan2_properColoc_Idxes);
                    
                    chan1ID_recur = chan1ID(~ismember(chan1ID, chan1ID_properColoc));
                    
                    chan1Pos_recur = chan1Positions(~ismember(chan1ID, chan1ID_properColoc),:);
                    
                    chan2PosID_recur = chan2PosID(~ismember(chan2PosID, chan2_properColoc_IDs));
                    chan2Pos_recur = chan2Positions_shifted(~ismember(chan2PosID, chan2_properColoc_IDs),:);
                    
                    pairs_recur = colocalizePosRecursive(p, chan1Pos_recur, ...
                        chan2Pos_recur, finalDist, chan1ID_recur, chan2PosID_recur);
                    
                    
                    pairs = [chan1ID_properColoc', chan2_properColoc_IDs'];
                    pairs = [pairs; pairs_recur];
                else
                    pairs = [currChan1ID', currChan2ID'];
                end
                
                
                
            end
            
        end
            
            
        function p = TwoChannelColocalizer(idMap, varargin)
            p.idMap = idMap;
            parser = inputParser;
            
            parser.addOptional('shiftFlag',true, @islogical); 
            
            % rename to: colocolization radius for chromatic shift
            % calculation
            parser.addOptional('initialDistance',2.5,@isnumeric);
            
            % coloc. radius for final colocolization.
            parser.addOptional('finalDistance',1.5,@isnumeric);
            
            parser.addOptional('xyPixelDistance',0.13,@isnumeric);
            parser.addOptional('zStepSize',0.35,@isnumeric);
            
            parser.addOptional('pixelShift', 0, @isnumeric);
            
            % Allowed z-plane difference in either direction
            parser.addOptional('zAllow', 3, @isnumeric);
            
            parser.parse(varargin{:});
            
            p.shiftFlag = parser.Results.shiftFlag;
            p.initialDistance = parser.Results.initialDistance;
            p.finalDistance = parser.Results.finalDistance;
            p.pixelShift = parser.Results.pixelShift;
            p.xyPixelDistance = parser.Results.xyPixelDistance;
            p.zStepSize = parser.Results.zStepSize; 
            p.zAllow = parser.Results.zAllow;
            
        end
        
%         % THE OLD PROCESSING FUNCTION
%         function p = oldRunMethod(p,inObj)
%             %Load in data from gaussian post-processor and place into dataset
%             pos_transformed = struct();
% 
%             
%             
%             % EXTRACT METHOD-----
%             for i = 1:numel(p.snpMap.channels)
%                 if isfield(inObj.channels.(p.snpMap.channels{i}).metadata,'gaussFitPostProc')
%                     
%                    % change ' to (:)
%                     x = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.xp';  %Draws data from post-processed fit
%                     y = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.yp';
%                     z = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.zp';
%                     
%                     numSpots(i) = length(x);
%                     
%                     p.data.(p.snpMap.channels{i}) = dataset();
%                     p.data.(p.snpMap.channels{i}).ID = [1:numSpots(i)]';
%                     p.data.(p.snpMap.channels{i}).position = [x, y, z];
%                     p.data.(p.snpMap.channels{i}).amplitude = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.amp';
%                     p.data.(p.snpMap.channels{i}).sigma = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.sig';
%                     
%                     pos_transformed.(p.snpMap.channels{i}) = [x, y, z * p.zDeform]; %temporarily store z-deformed coordinates for localization
%                     
%                     if isempty(pos_transformed.(p.snpMap.channels{i}))
%                         pos_transformed.(p.snpMap.channels{i}) = zeros(0,3); %set data equal to zero so that things work later
%                     end
%                     
%                 else
% 
%                     % Should be an error. Won't be necessary in newest version. 
%                     fprintf('Have to run gaussFitPostProc first\n');
%                 end
%             end
%             
%             
%             
%             guidePositions = pos_transformed.(p.snpMap.channels{1}); %for clarity
%             pairs = cell(2,1); %Cell array to store IDs of pairs
%             
%             shift{1} = zeros(numSpots(1),3);
%             shift{2} = zeros(numSpots(1),3);
%             
%             
%             % Extract method : colocolize to guide
%             for i = 2:3
%                 %Finds the minimum pairwise distance between the guide and
%                 %snp probe and filters it the initial cutoff radius
%                 snpPositions = pos_transformed.(p.snpMap.channels{i});
%                 pairwiseDist = pdist2(guidePositions, snpPositions);
%                 
%                 % for each guide get closest snp
%                 [minGuideDistances, snp_ID] = min(pairwiseDist', [], 1);
%                 
%                 % find guides and SNPs that have snp within < initialDistance
%                 guide_colocalized_ID = find(minGuideDistances < p.initialDistance)';
%                 snp_colocalized_ID = snp_ID(guide_colocalized_ID)';
%                 
%                 % chromatic shift for each one of these
%                 % try to make dimensions involved more explicit
%                 totalShift = guidePositions(guide_colocalized_ID,:) ...
%                         - snpPositions(snp_colocalized_ID,:);
%                 medianShift = median(totalShift);
%                 
%                 % flag decides whether to go on to next stage of
%                 % colocolization
%                 
%                 % It looks like this is always assumed true, to get pairs
%                 % and shift.
%                 % rename shfitFlag.
%                 if p.shiftFlag
%                     %apply median shift
%                     snpPositions_shifted = bsxfun(@plus, snpPositions, medianShift);
%                     %repeat colocalization
%                     pairwiseDist = pdist2(guidePositions, snpPositions_shifted);
%                     [minGuideDistances, snp_ID] = min(pairwiseDist', [], 1);
%                     % uses finalDistance
%                     guide_colocalized_ID = find(minGuideDistances < p.finalDistance)';
%                     snp_colocalized_ID = snp_ID(guide_colocalized_ID)';
%                     
%                     
%                     % move out of loop if want to keep shiftflag= false option.
%                     pairs{i-1} = [guide_colocalized_ID, snp_colocalized_ID];
%                     shift{i-1}(guide_colocalized_ID,:) = guidePositions(guide_colocalized_ID,:) ...
%                         - snpPositions(snp_colocalized_ID,:);
%                 end
%             end
%             %   ------
% 
%             %Create Labels for guide probe
%             
%             % idx_guide -> number of colocolized SNPs.
%             idx_guide = zeros(numSpots(1), 1);
%             
%             % should be more explicit.
%             %0 for undetected SNP, 1 for detected SNP, 2 for two-color co-localization
%             idx_guide(pairs{1}(:,1)) = idx_guide(pairs{1}(:,1)) + 1;
%             idx_guide(pairs{2}(:,1)) = idx_guide(pairs{2}(:,1)) + 1;
%             
%             Labels = cell(numSpots(1),1);     %Vector that idenitifies the label of each guide probe
%             Labels(idx_guide == 0) = cellstr('undetec');
%             Labels(pairs{1}(:,1)) = p.snpMap.names(2);
%             Labels(pairs{2}(:,1)) = p.snpMap.names(3);
%             Labels(idx_guide == 2) = cellstr('3-color'); %order matters here
%             
%             levels = {p.snpMap.names{2}, p.snpMap.names{3}, 'undetec', '3-color'};
%             labels = nominal();
%             labels = addlevels(labels, levels);
%             p.data.(p.snpMap.channels{1}).labels = vertcat(labels, nominal(Labels));
%             
%             %   %%  %%
%             % CONTINUE HERE
%             %   %%  %%
%             
% %             levelsToAdd_idx = ~ismember(levels, getlevels(p.data.(p.snpMap.channels{1}).labels));
% %             if any(levelsToAdd_idx)
% %             p.data.(p.snpMap.channels{1}).labels = addlevels(p.data.(p.snpMap.channels{1}).labels, ...
% %                 cellstr(levels(levelsToAdd_idx)));
% %             end
%             
%             snpA_neighbors = zeros(numSpots(1),1);
%             snpB_neighbors = zeros(numSpots(1),1);
%             
%             snpA_amplitude = zeros(numSpots(1),1);
%             snpB_amplitude = zeros(numSpots(1),1);
%             
%             snpA_neighbors(pairs{1}(:,1)) = pairs{1}(:,2);
%             snpB_neighbors(pairs{2}(:,1)) = pairs{2}(:,2);
%             
%             snpA_amplitude(pairs{1}(:,1)) = p.data.(p.snpMap.channels{2}).amplitude(pairs{1}(:,2));
%             snpB_amplitude(pairs{2}(:,1)) = p.data.(p.snpMap.channels{3}).amplitude(pairs{2}(:,2));
% 
%             neighborSet = dataset({snpA_neighbors, [p.snpMap.channels{2}, '_neighbors']}, ...
%                 {shift{1}, [p.snpMap.channels{2}, '_shift']}, ...
%                 {snpA_amplitude, [p.snpMap.channels{2}, '_amplitude']}, ...
%                 {snpB_neighbors, [p.snpMap.channels{3}, '_neighbors']}, ...
%                 {shift{2}, [p.snpMap.channels{3}, '_shift']}, ...
%                 {snpB_amplitude, [p.snpMap.channels{3}, '_amplitude']});
%             
%             p.data.(p.snpMap.channels{1}) = horzcat(p.data.(p.snpMap.channels{1}), neighborSet);
%             
%             
%             %Get Labels for SNPS
%             three_color_spots_ID = find(idx_guide == 2);
%             for i = 2:3
%                 Labels = []; %Clear variable
%                 
%                 snp_3color_pairs_index = find(ismember(pairs{i-1}(:,1), three_color_spots_ID));
%                 snp_3color_IDs = pairs{i-1}(snp_3color_pairs_index,2);
%                 
%                 Labels = cellstr(repmat('undetec', numSpots(i),1));
%                 Labels(pairs{i-1}(:,2)) = p.snpMap.names(i);
%                 Labels(snp_3color_IDs) = cellstr('3-color');
%                 
%                 labels = nominal();
%                 labels = addlevels(labels, levels);
%                 p.data.(p.snpMap.channels{i}).labels = vertcat(labels, nominal(Labels));
%                 
% %                 p.data.(p.snpMap.channels{i}).labels = nominal(Labels);
% %                 levelsToAdd_idx = ~ismember(levels, getlevels(p.data.(p.snpMap.channels{i}).labels));
% %                 
% %                 if any(levelsToAdd_idx)
% %                 p.data.(p.snpMap.channels{i}).labels = addlevels(p.data.(p.snpMap.channels{i}).labels, ...
% %                 cellstr(levels(levelsToAdd_idx)));
% %                 end
%             
%                 
%                 p.data.(p.snpMap.channels{i}).guide_neighbors = zeros(numSpots(i),1);
%                 p.data.(p.snpMap.channels{i}).guide_neighbors(pairs{i-1}(:,2)) = pairs{i-1}(:,1);
%             end
% 
%             
%         end
        
%         function showSNP(p,inObj,whichLabel)
%             % Plots all spots on max merge of guide probe channel and
%             % single SNP channel as labeled by whichLabel
%             if p.isProcessed % If the processor has already been run
%                 
%                 idx_snpMap_vector = find(strcmp(p.snpMap.names, whichLabel));
%                 snpChannel = p.snpMap.channels{idx_snpMap_vector};
%                 
%                 img = inObj.channelStk(p.snpMap.channels{1});
%                 
%                 shift = ['medDiff_1', num2str(idx_snpMap_vector)]; %Set which shift we are colocalizing with respect to
%                 posSNP = ['pos_', num2str(idx_snpMap_vector)];
%                 
%                 guidePositions = p.pos_1;
%                 snpPositions = p.(posSNP);
%                 shifts = p.(shift);
%                 snpPositions = bsxfun(@plus, snpPositions, shifts);
%                 
%                 imgmax = max(img,[],3);  %MAX MERGE
%                 
%                 hold off;
%                 imgmax = imadjust(imgmax,[0.3 0.5],[]);
%                 imshow(imgmax,[]);  %Plot image
%                 
%                 hold on;
%                 plot(guidePositions(:,2),guidePositions(:,1),'go');  % First the ref channel in green
%                 plot(snpPositions(:,2), snpPositions(:,1), 'co');  % other channel in cyan
%                 plot(guidePositions(p.labels_1 == whichLabel,2), guidePositions(p.labels_1 == whichLabel,1),'mo','markersize',10); %Plot the co_localized spots
%                 
%                 hold off;
%             else
%                 fprintf('Colocalization analysis not run yet.\n');
%             end;
%         end;
        
%         function showResults(p, inObj)
%             
%             if p.isProcessed % If the processor has already been run
%                 img = inObj.channelStk(p.snpMap.channels{1}); %Get image in guide channel
%                 guidePositions = p.pos_1;
%                 
%                 snpA_IDs = p.neighborIDs_1(:,1);
%                 snpB_IDs = p.neighborIDs_1(:,2);
%                 
%                 snpAidx = snpA_IDs(snpA_IDs > 0);
%                 snpBidx = snpB_IDs(snpB_IDs > 0);
%                 
%                 snpAPositions = p.pos_2;
%                 snpBPositions = p.pos_3;
%                 
%                 snpAPositions = snpAPositions(snpAidx,:);
%                 snpBPositions = snpBPositions(snpBidx,:);
%                 
%                 snpAPositions = bsxfun(@plus, snpAPositions, p.medDiff_12);  %Add in the median shift
%                 snpBPositions = bsxfun(@plus, snpBPositions, p.medDiff_13);
%                 
%                 imgmax = max(img,[],3);  %MAX MERGE
%                 
%                 hold off;
%                 spotsPic = figure;
%                 
%                 imshow(imgmax,[]);  %Plot image
%                 
%                 %
%                 hold on;
%                 plot(guidePositions(:,2),guidePositions(:,1),'yo');  % First the ref channel in green
%                 plot(guidePositions(p.labels_1 == p.snpMap.names{2},2), guidePositions(p.labels_1 == p.snpMap.names{2},1),'co','markersize',10); %Plot the co_localized spots
%                 plot(guidePositions(p.labels_1 == p.snpMap.names{3},2), guidePositions(p.labels_1 == p.snpMap.names{3},1),'mo','markersize',10); %Plot the co_localized spots
%                 
%                 color3_idx =  p.labels_1 == '3-color';
%                 
%                 intensities2 = [p.intensity_2(p.neighborIDs_1(color3_idx, 1)), p.intensity_2(p.neighborIDs_1(p.labels_1 == p.snpMap.names{2},1))];
%                 intensities3 = [p.intensity_3(p.neighborIDs_1(color3_idx, 2)), p.intensity_3(p.neighborIDs_1(p.labels_1 == p.snpMap.names{3},2))];
%                 
%                 [n xout] = hist(intensities2, 500);
%                 xout(end) = max(intensities2);
%                 percentile2 = cumsum(n./length(intensities2));
%                 [n2 xout2] = hist(intensities3, 500);
%                 xout2(end) = max(intensities3);
%                 percentile3 = cumsum(n2./length(intensities3));
%                 
%                 snpIntensity = [p.intensity_2(p.neighborIDs_1(color3_idx, 1))', p.intensity_3(p.neighborIDs_1(color3_idx, 2))'] %Intensity of spots
%                 snpPercentiles = [];
%                 for i = 1:length(snpIntensity)
%                     snpPercentiles = [snpPercentiles; percentile2(find(xout >= snpIntensity(i,1), 1,'first')), percentile3(find(xout2 >= snpIntensity(i,2), 1,'first'))];
%                     color3_2(i) = percentile2(find(xout >= snpIntensity(i,1), 1,'first')) > percentile3(find(xout2 >= snpIntensity(i,2), 1,'first'));
%                 end
%                 
%                 color3guides = guidePositions(color3_idx,:);
%                 
%                 plot(color3guides(color3_2, 2), color3guides(color3_2, 1), 'co', 'markersize',10)
%                 plot(color3guides(~color3_2, 2), color3guides(~color3_2, 1), 'mo', 'markersize',10)
%                 legend(p.snpMap.names)
%                 
%                 name = inObj(1).channels.gfp.filename;
%                 name = name(4:6);
%                 
%                 print(spotsPic, '-dtiff', ['spots', name]);
%                 
%                 hold off;
%                 
%                 %                 intensityPic = figure;
%                 %                 scatter(snpIntensity(:,1), snpIntensity(:,2));
%                 %                 title('Intensity Scatter');
%                 %                 xlabel([p.snpMap.names{2}, ' pixel intensity']);
%                 %                 ylabel([p.snpMap.names{3}, ' pixel intenisty']);
%                 %                 print(intensityPic, '-djpeg', ['intensity', name]);
%                 
%                 
%                 %                 percentilePic = figure;
%                 %                 scatter(snpPercentiles(:,1), snpPercentiles(:,2));
%                 %                 title('Percentile Scatter');
%                 %                 xlabel(p.snpMap.names{2});
%                 %                 ylabel(p.snpMap.names{3});
%                 %                 print(percentilePic, '-djpeg', ['percentile', name]);
%                 %                 close all
%                 %
%                 
%             else
%                 fprintf('Colocalization analysis not run yet.\n');
%             end;
%             
%         end
        
    end
    
end






