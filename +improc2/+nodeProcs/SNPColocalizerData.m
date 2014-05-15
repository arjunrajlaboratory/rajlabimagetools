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

classdef SNPColocalizerData < improc2.interfaces.ProcessedData;
    
    
    properties
        needsUpdate = true;
    end
    
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.FittedSpotsContainer', ...
            'improc2.interfaces.FittedSpotsContainer', ...
            'improc2.interfaces.FittedSpotsContainer'};
        dependencyDescriptions = {'fitted guide', 'fitted snpA', 'fitted snpB'};
    end
    
    properties
        metadata
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
    end
    
    methods
        function p = SNPColocalizerData(snpMap, varargin)
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
            
            parser.parse(varargin{:});
            
            p.shiftFlag = parser.Results.shiftFlag;
            p.initialDistance = parser.Results.initialDistance;
            p.finalDistance = parser.Results.finalDistance;
            p.zDeform = parser.Results.zDeform;
            
        end
        
        function p = run(p, guideFittedSpotsHolder, snpAFittedSpotsHolder, snpBFittedSpotsHolder)
            fprintf('Currently run does nothing\n');
        end
        
        % THE OLD PROCESSING FUNCTION
        function p = oldRunMethod(p,inObj)
            %Load in data from gaussian post-processor and place into dataset
            pos_transformed = struct();

            
            
            % EXTRACT METHOD-----
            for i = 1:numel(p.snpMap.channels)
                if isfield(inObj.channels.(p.snpMap.channels{i}).metadata,'gaussFitPostProc')
                    
                   % change ' to (:)
                    x = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.xp';  % Draws data from post-processed fit
                    y = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.yp';
                    z = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.zp';
                    
                    numSpots(i) = length(x);
                    
                    p.data.(p.snpMap.channels{i}) = dataset();
                    p.data.(p.snpMap.channels{i}).ID = [1:numSpots(i)]';
                    p.data.(p.snpMap.channels{i}).position = [x, y, z];
                    p.data.(p.snpMap.channels{i}).amplitude = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.amp';
                    p.data.(p.snpMap.channels{i}).sigma = inObj.channels.(p.snpMap.channels{i}).metadata.gaussFitPostProc.sig';
                    
                    pos_transformed.(p.snpMap.channels{i}) = [x, y, z * p.zDeform]; % temporarily store z-deformed coordinates for localization
                    
                    if isempty(pos_transformed.(p.snpMap.channels{i}))
                        pos_transformed.(p.snpMap.channels{i}) = zeros(0,3); % set data equal to zero so that things work later
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
                
                snp_3color_pairs_index = find(ismember(pairs{i-1}(:,1), three_color_spots_ID));
                snp_3color_IDs = pairs{i-1}(snp_3color_pairs_index,2);
                
                Labels = cellstr(repmat('undetec', numSpots(i),1));
                Labels(pairs{i-1}(:,2)) = p.snpMap.names(i);
                Labels(snp_3color_IDs) = cellstr('3-color');
                
                labels = nominal();
                labels = addlevels(labels, levels);
                p.data.(p.snpMap.channels{i}).labels = vertcat(labels, nominal(Labels));
                
                
                p.data.(p.snpMap.channels{i}).guide_neighbors = zeros(numSpots(i),1);
                p.data.(p.snpMap.channels{i}).guide_neighbors(pairs{i-1}(:,2)) = pairs{i-1}(:,1);
            end 
        end         
    end
end