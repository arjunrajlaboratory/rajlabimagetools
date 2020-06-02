function addClickedSpotsData(objectHandle, varargin)
%Builds the data nodes for trasncription sites. If there is an intorn
%channel passed, it will build a data node for intron and exons. Otherwise
%it builds an exon only data node.

ip = inputParser;
ip.addParameter('channels', []);
ip.addParameter('nodeName', 'ManuallyClickedSpots', @ischar);
ip.addParameter('dirPathOrAnArrayCollection', pwd);

ip.parse(varargin{:});
    
dataAdder = improc2.processing.DataAdder(ip.Results.dirPathOrAnArrayCollection);

fprintf('** Adding data templates ...')


parentNodeLabels = {};

if ~isempty(ip.Results.channels)
    channels = ip.Results.channels;
else
    channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
end

for i = 1:length(channels)
    parentNodeLabels = [parentNodeLabels, strcat(channels{i}, ':Fitted')];
end
label = ip.Results.nodeName;
n_channels = length(channels);

if n_channels == 1
    dataAdder.addDataToObject(improc2.txnSites3.clickedSpotsCollection_one(objectHandle), parentNodeLabels, label)
elseif n_channels == 2
    dataAdder.addDataToObject(improc2.txnSites3.clickedSpotsCollection_two(objectHandle), parentNodeLabels, label)
elseif n_channels == 3
    dataAdder.addDataToObject(improc2.txnSites3.clickedSpotsCollection_three(objectHandle), parentNodeLabels, label)
elseif n_channels == 4
    dataAdder.addDataToObject(improc2.txnSites3.clickedSpotsCollection_four(objectHandle), parentNodeLabels, label)
elseif n_channels == 5
    dataAdder.addDataToObject(improc2.txnSites3.clickedSpotsCollection_five(objectHandle), parentNodeLabels, label)
end
dataAdder.repeatForAllObjectsAndQuit();
end

