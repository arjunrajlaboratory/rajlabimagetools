function ExtractTxnSiteData(outputMethod, typeTxnSite, varargin)

% This is the Extractor for transcription site data from the TxnSites2 GUI.
% This extractor should be used after the data has been processed using the
% TxnSites2 GUI. The table output that this function generates will contain
% number of spots, X-coordinates, Y-coordinates, and intensities of the
% exon channel and intron channel (optional), and the number and
% intensities of the identified transcription sites (either coloc or exon
% only). There is also an option to extract the exact points that the user
% clicked on while processing the data instead of the closest exon Xs and
% Ys. 
%
% The usage of the function is described below.
%
% Usage: ExtractTxnSiteData(outputMethod, typeTxnSite, varargin) where-
%           -outputMethod can either be 'molten' or 'solid'
%           -typeTxnSite can either be 'exonintron' (for colocalized
%               transcription sites), or 'exononly' (for exon only
%               transcription sites)
%           -varargin: 
%               > For exonintron txn sites, provide the exon channel and
%                   intron channel node names and the third and fourth inputs
%                   respectively. These should be strings with the 
%                   conventional name for dye colors ('alexa', 'tmr', 'cy',
%                   'nir', 'gfp').
%               > For exononly txn sites, provide the exon channel node
%                   name as the third input.
%               > After the channel node names, you can pass a string
%                   'getClickedPoints' as the next input if you want the
%                   actual clicked points to be included in the output
%                   table. In the absense of this input, the extractor will
%                   only output the coordinates of the closest exon
%                   to the clicked point as identified by the processor.
% Example: 
% - ExtractTxnSiteData('molten', 'exonintron', 'alexa', 'tmr',
%   'getClickedPoints') will output a molten format table with the data from
%   the alexatmr:TxnSites node, and the coordinates of the actual points that
%   the user clicked.
% - ExtractTxnSiteData('solid', 'exononly', 'alexa') will output a solid
%   format table with data from the node alexa:TxnSites.

validateattributes(varargin{1}, {'char'}, {'nonempty'})
validateattributes(outputMethod, {'char'}, {'nonempty'})
validateattributes(typeTxnSite, {'char'}, {'nonempty'})

if strcmp(typeTxnSite, 'exonintron')
    exonChannel = varargin{1};
    intronChannel = varargin{2};
    validateattributes(intronChannel, {'char'}, {'nonempty'})
elseif strcmp(typeTxnSite, 'exononly')
    exonChannel = varargin{1};
else
    error('Invalid input. Second argument can either be "exonintron" or "exononly".')
end

contents = dir('data*');
tools = improc2.launchImageObjectTools;
iterator = tools.iterator;

numberOfObjects = 0;
for i = 1:numel(contents)
    load(contents(i).name);
    numberOfObjects = numberOfObjects + numel(objects);
end

objectNumber = [];
arrayNumber = [];
%Exon Stuff
numExonSpots = [];
exonXs = [];
exonYs = [];
exonIntensities = [];
exonFittedIntensities = [];
%Intron stuff
numIntronSpots = [];
intronXs = [];
intronYs = [];
intronIntensities = [];
intronFittedIntensities = [];
%Txn sites coloc stuff
numTxnSites = [];
txnSitesIntensities = [];

% Molten Format Table
if strcmp(outputMethod, 'molten')
    for i = 1:numberOfObjects
        if(~tools.annotations.getValue('isGood'))
            iterator.goToNextObject;
            continue;
        end
        arrayNumber = tools.navigator.currentArrayNum;
        objectNumber = tools.navigator.currentObjNum;
        
        if strcmp(typeTxnSite, 'exononly') && tools.objectHandle.hasData(strcat(exonChannel, ':TxnSites'))
            % Extract number exon spots
            numExonSpots = [numExonSpots, [arrayNumber; objectNumber; tools.objectHandle.getOverThreshSpots(strcat(exonChannel, ':Spots'))]];
            
            % Extract exon mRNA intensities
            lengthIntensities = numel(tools.objectHandle.getMoltenFittedIntensities(strcat(exonChannel, ':Fitted')));
            exonFittedIntensities = [exonFittedIntensities, [ones(1, lengthIntensities)*arrayNumber; ...
                                                 ones(1, lengthIntensities)*objectNumber; ...
                                                 tools.objectHandle.getMoltenFittedIntensities(strcat(exonChannel, ':Fitted'))]];
            
            % Extract exon only txn site coordinates
            lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs);
            exonXs = [exonXs, [ones(1, lengthCoords)*arrayNumber; ...
                                               ones(1, lengthCoords)*objectNumber; ...
                                               tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs']];
            exonYs = [exonYs, [ones(1, lengthCoords)*arrayNumber; ...
                                               ones(1, lengthCoords)*objectNumber; ...
                                               tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Ys']];
            
            % Extract number exon only txn site exon spots
            numTxnSites = [numTxnSites, [arrayNumber; objectNumber; numel(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs)]];
            
            % Extract exon only txn site intensities
            lengthIntensities = numel(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Intensity);
            txnSitesIntensities = [txnSitesIntensities, ...
                                                    [ones(1, lengthIntensities)*arrayNumber; ...
                                                     ones(1, lengthIntensities)*objectNumber; ...
                                                     tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Intensity]];  
        elseif strcmp(typeTxnSite, 'exonintron') && tools.objectHandle.hasData(strcat(exonChannel, intronChannel, ':TxnSites'))
            % Extract number exon spots
            numExonSpots = [numExonSpots, [arrayNumber; objectNumber; tools.objectHandle.getOverThreshSpots(strcat(exonChannel, ':Spots'))]];

            % Extract Exon mRNA intensity
            exonMrnaIntensities = tools.objectHandle.getMoltenFittedIntensities(strcat(exonChannel, ':Fitted'));
            exonFittedIntensities = [exonFittedIntensities, ...
                [ones(1, numel(exonMrnaIntensities))*arrayNumber; ...
                 ones(1, numel(exonMrnaIntensities))*objectNumber; ...
                 exonMrnaIntensities]];

            % Extract coloc txn site exon coordinates
            lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonXs);
            exonXs = [exonXs, [ones(1, lengthCoords)*arrayNumber; ...
                               ones(1, lengthCoords)*objectNumber; ...
                               tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonXs']];
            exonYs = [exonYs, [ones(1, lengthCoords)*arrayNumber; ...
                               ones(1, lengthCoords)*objectNumber; ...
                               tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonYs']];

            % Extract number intron spots
            numIntronSpots = [numIntronSpots, ...
                              [arrayNumber; objectNumber; tools.objectHandle.getOverThreshSpots(strcat(intronChannel, ':Spots'))]];

            % Extract intron mRNA intensities
            lengthIntronIntensities = numel(tools.objectHandle.getMoltenFittedIntensities(strcat(intronChannel, ':Fitted')));
            intronFittedIntensities = [intronFittedIntensities, ...
                                     [ones(1, lengthIntronIntensities)*arrayNumber; ...
                                      ones(1, lengthIntronIntensities)*objectNumber;
                                      tools.objectHandle.getMoltenFittedIntensities(strcat(intronChannel, ':Fitted'))]];

            % Extract coloc txn site intron coordinates
            lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronXs);
            intronXs = [intronXs, [ones(1, lengthCoords)*arrayNumber; ...
                                   ones(1, lengthCoords)*objectNumber; ...
                                   tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronXs']];
            intronYs = [intronYs, [ones(1, lengthCoords)*arrayNumber; ...
                                   ones(1, lengthCoords)*objectNumber; ...
                                   tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronYs']];
            intronIntensities = [intronIntensities, [ones(1, lengthCoords)*arrayNumber; ...
                                   ones(1, lengthCoords)*objectNumber; ...
                                   tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronIntensity]];

            % Extract number coloc txn sites
            numTxnSites = [numTxnSites, ...
                                [arrayNumber; objectNumber; numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ColocXs)]];

            % Extract coloc txn sites intensities
            lengthIntensities = numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ColocIntensity);
            txnSitesIntensities = [txnSitesIntensities, ...
                                                [ones(1, lengthIntensities)*arrayNumber; ...
                                                 ones(1, lengthIntensities)*objectNumber; ...
                                                 tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ColocIntensity]];
        elseif nargin < 3 && ~tools.objectHandle.hasData(strcat(exonChannel, ':TxnSites'))
            error('The node %s does not exist. Please run "improc2.viewImageObjectDataGraph" and confirm.', strcat(exonChannel, ':TxnSites'))
        elseif nargin >= 3 && ~tools.objectHandle.hasData(strcat(exonChannel, intronChannel, ':TxnSites'))
            error('The node %s does not exist. Please run "improc2.viewImageObjectDataGraph" and confirm.', strcat(exonChannel, intronChannel, ':TxnSites'))
        end
        iterator.goToNextObject;
    end
    
    numExonSpots = num2cell(numExonSpots'); numExonSpots(1:end, 4) = {'numExonSpots'};
    exonXs = num2cell(exonXs'); exonXs(1:end, 4) = {'exonXs'};
    exonYs = num2cell(exonYs'); exonYs(1:end, 4) = {'exonYs'};
    exonFittedIntensities = num2cell(exonFittedIntensities'); exonFittedIntensities(1:end, 4) = {'exonIntensities'};
    numIntronSpots = num2cell(numIntronSpots'); numIntronSpots(1:end, 4) = {'numIntronSpots'};
    intronXs = num2cell(intronXs'); intronXs(1:end, 4) = {'intronXs'};
    intronYs = num2cell(intronYs'); intronYs(1:end, 4) = {'intronYs'};
    intronFittedIntensities = num2cell(intronFittedIntensities'); intronFittedIntensities(1:end, 4) = {'intronIntensities'};
    intronIntensities = num2cell(intronIntensities'); intronIntensities(1:end, 4) = {'txnSitesIntronIntensities'};
    numTxnSites = num2cell(numTxnSites'); numTxnSites(1:end, 4) = {'numTxnSites'};
    txnSitesIntensities = num2cell(txnSitesIntensities'); txnSitesIntensities(1:end, 4) = {'txnSitesExonIntensities'};
    
    fprintf('Making value data\n')
    ValueData = [numExonSpots; exonXs; exonYs; exonFittedIntensities; numIntronSpots; intronXs; intronYs; ...
        intronFittedIntensities; intronIntensities; numTxnSites; txnSitesIntensities];
    fprintf('Making Table\n')
    BigTable = cell2table(ValueData);
    fprintf('Writing Table\n')
    writetable(BigTable, 'BigTable.txt')
    
% Solid Format Table
elseif strcmp(outputMethod, 'solid')
    for i = 1:numberOfObjects
        if(~tools.annotations.getValue('isGood'))
            iterator.goToNextObject;
            continue;
        end
        arrayNumber = [arrayNumber; tools.navigator.currentArrayNum];
        objectNumber = [objectNumber; tools.navigator.currentObjNum];
        
        if strcmp(typeTxnSite, 'exononly') && tools.objectHandle.hasData(strcat(exonChannel, ':TxnSites'))
            % Extract number exon spots
            numExonSpots = [numExonSpots; tools.objectHandle.getOverThreshSpots(strcat(exonChannel, ':Spots'))];
            
            % Extract exon mRNA intensities
            exonFittedIntensities = [exonFittedIntensities; mean(tools.objectHandle.getMoltenFittedIntensities(strcat(exonChannel, ':Fitted')))];
            
            % Extract exon only txn site coordinates
%             lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs);
%             exonXs = [exonXs, [ones(1, lengthCoords)*arrayNumber; ...
%                                                ones(1, lengthCoords)*objectNumber; ...
%                                                tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs']];
%             exonYs = [exonYs, [ones(1, lengthCoords)*arrayNumber; ...
%                                                ones(1, lengthCoords)*objectNumber; ...
%                                                tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Ys']];
            
            % Extract number exon only txn site exon spots
            numTxnSites = [numTxnSites; numel(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Xs)];
            
            % Extract exon only txn site intensities
            txnSitesIntensities = [txnSitesIntensities; mean(tools.objectHandle.getData(strcat(exonChannel, ':TxnSites')).Intensity)];
        elseif strcmp(typeTxnSite, 'exonintron') && tools.objectHandle.hasData(strcat(exonChannel, intronChannel, ':TxnSites'))
            % Extract number exon spots
            numExonSpots = [numExonSpots; tools.objectHandle.getOverThreshSpots(strcat(exonChannel, ':Spots'))];

            % Extract Exon mRNA intensity
            exonMrnaIntensities = tools.objectHandle.getMoltenFittedIntensities(strcat(exonChannel, ':Fitted'));
            exonFittedIntensities = [exonFittedIntensities; mean(exonMrnaIntensities)];

            % Extract coloc txn site exon coordinates
%             lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonXs);
%             exonXs = [exonXs, [ones(1, lengthCoords)*arrayNumber; ...
%                                ones(1, lengthCoords)*objectNumber; ...
%                                tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonXs']];
%             exonYs = [exonYs, [ones(1, lengthCoords)*arrayNumber; ...
%                                ones(1, lengthCoords)*objectNumber; ...
%                                tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ExonYs']];

            % Extract number intron spots
            numIntronSpots = [numIntronSpots; tools.objectHandle.getOverThreshSpots(strcat(intronChannel, ':Spots'))];

            % Extract intron mRNA intensities
            intronFittedIntensities = [intronFittedIntensities; mean(tools.objectHandle.getMoltenFittedIntensities(strcat(intronChannel, ':Fitted')))];

            % Extract coloc txn site intron coordinates
%             lengthCoords = numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronXs);
%             intronXs = [intronXs, [ones(1, lengthCoords)*arrayNumber; ...
%                                    ones(1, lengthCoords)*objectNumber; ...
%                                    tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronXs']];
%             intronYs = [intronYs, [ones(1, lengthCoords)*arrayNumber; ...
%                                    ones(1, lengthCoords)*objectNumber; ...
%                                    tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).IntronYs']];

            % Extract number coloc txn sites
            numTxnSites = [numTxnSites; numel(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ColocXs)];

            % Extract coloc txn sites intensities
            txnSitesIntensities = [txnSitesIntensities; mean(tools.objectHandle.getData(strcat(exonChannel, intronChannel, ':TxnSites')).ColocIntensity)];
            
        elseif nargin < 3 && ~tools.objectHandle.hasData(strcat(exonChannel, ':TxnSites'))
            error('The node %s does not exist. Please run "improc2.viewImageObjectDataGraph" and confirm.', strcat(exonChannel, ':TxnSites'))
        elseif nargin >= 3 && ~tools.objectHandle.hasData(strcat(exonChannel, intronChannel, ':TxnSites'))
            error('The node %s does not exist. Please run "improc2.viewImageObjectDataGraph" and confirm.', strcat(exonChannel, intronChannel, ':TxnSites'))
        end
        iterator.goToNextObject;
    end
    
    arrayNumber = num2cell(arrayNumber); arrayNumber(end+1) = {'arrayNumber'};
    objectNumber = num2cell(objectNumber); objectNumber(end+1) = {'objectNumber'};
    numExonSpots = num2cell(numExonSpots); numExonSpots(end+1) = {'numExonSpots'};
%     exonXs = num2cell(exonXs); exonXs(end+1) = {'exonXs'};
%     exonYs = num2cell(exonYs); exonYs(end+1) = {'exonYs'};
    exonFittedIntensities = num2cell(exonFittedIntensities); exonFittedIntensities(end+1) = {'meanExonIntensities'};
    numIntronSpots = num2cell(numIntronSpots); numIntronSpots(end+1) = {'numIntronSpots'};
%     intronXs = num2cell(intronXs); intronXs(end+1) = {'intronXs'};
%     intronYs = num2cell(intronYs); intronYs(end+1) = {'intronYs'};
    intronFittedIntensities = num2cell(intronFittedIntensities); intronFittedIntensities(end+1) = {'meanIntronIntensities'};
    numTxnSites = num2cell(numTxnSites); numTxnSites(end+1) = {'numTxnSites'};
    txnSitesIntensities = num2cell(txnSitesIntensities); txnSitesIntensities(end+1) = {'meanTxnSitesIntensities'};
    
    fprintf('Making value data\n')
    ValueData = [arrayNumber, objectNumber, numExonSpots, exonFittedIntensities, numIntronSpots, ...
        intronFittedIntensities, numTxnSites, txnSitesIntensities];
    fprintf('Making Table\n')
    BigTable = cell2table(ValueData);
    fprintf('Writing Table\n')
    writetable(BigTable, 'BigTable.txt')
end
end