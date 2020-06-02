function launchGUI(varargin)

ip = inputParser;
ip.addParameter('dir', pwd);
ip.addParameter('channels',[]);
ip.addParameter('nodeName', 'ManuallyClickedSpots', @ischar);
ip.parse(varargin{:});


% improc2.processing.updateAll(ip.Results.dir); 


tools = improc2.launchImageObjectBrowsingTools(ip.Results.dir);
objectHandle = tools.objectHandle;
navigator = tools.navigator;

if ~isempty(ip.Results.channels)
    channels = ip.Results.channels;
else
    channels = improc2.thresholdGUI.findRNAChannels(objectHandle);
end
% addClickedSpotsData(tools.objectHandle,'channels', ip.Results.channels, 'dirPathOrAnArrayCollection', ip.Results.dir, 'nodeName', ip.Results.nodeName)


n_channels = length(channels);

if n_channels == 1
    nodeDataBasedManualSpots2Collection = improc2.txnSites3.clickedSpotsCollection_one(tools.objectHandle, 'nodeName', ip.Results.nodeName, 'channels', channels);
elseif n_channels == 2
    nodeDataBasedManualSpots2Collection = improc2.txnSites3.clickedSpotsCollection_two(tools.objectHandle, 'nodeName', ip.Results.nodeName, 'channels', channels);
elseif n_channels == 3
    nodeDataBasedManualSpots2Collection = improc2.txnSites3.clickedSpotsCollection_three(tools.objectHandle, 'nodeName', ip.Results.nodeName, 'channels', channels);
elseif n_channels == 4
    nodeDataBasedManualSpots2Collection = improc2.txnSites3.clickedSpotsCollection_four(tools.objectHandle, 'nodeName', ip.Results.nodeName, 'channels', channels);
elseif n_channels == 5
    nodeDataBasedManualSpots2Collection = improc2.txnSites3.clickedSpotsCollection_five(tools.objectHandle, 'nodeName', ip.Results.nodeName, 'channels', channels);
end




controls = improc2.txnSites3.launchGUI2Core(tools,channels, 'nodeName', ip.Results.nodeName);
controls = improc2.txnSites3.displayImages(controls);
controls.imageWindowController.launchGUI()


navigator.addActionBeforeMoveAttempt(nodeDataBasedManualSpots2Collection,...
    @flagAsReviewed);
