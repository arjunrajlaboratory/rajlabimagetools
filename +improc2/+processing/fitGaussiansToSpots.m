function fitGaussiansToSpots(dirPathOrAnArrayCollection, channelsToFit)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    
    tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
    
    postProcessorDataUnProcessed = improc2.procs.TwoStageGaussianSpotFitProcessorData();
    
    fittableChannels = detectChannelsWithSpots(tools.objectHandle, postProcessorDataUnProcessed);
    
    if nargin < 2
        channelsToFit = fittableChannels;
    end
    assert(all(ismember(channelsToFit, fittableChannels)), ...
        'At least one of the requested channels does not have the processorData needed to do gaussian fits')
    
    croppedImgProvider = improc2.utils.buildCroppedImageProvider(dirPathOrAnArrayCollection);
    
    fprintf('Adding unprocessed gaussian fit processorData to all objects\n')
    createProcessorDataInAllObjects(...
        tools.iterator, ...
        tools.processorRegistrar, ...
        dentist.utils.makeFilledChannelArray(channelsToFit, @(x) postProcessorDataUnProcessed));
    
    fprintf('Starting to run the gaussian fits\n')
    for channelName = channelsToFit
        improc2.processing.runSingleChannelProcessorOnAllImageObjects(...
            tools.objectHandle, ...
            tools.iterator, ...
            croppedImgProvider, ...
            char(channelName), ...
            class(postProcessorDataUnProcessed), ...
            'last')
    end
end


function spotsChannels = detectChannelsWithSpots(objectHandle, postProcessorData)
    spotsChannels = {};
    for channelName = objectHandle.channelNames
       if objectHandle.hasProcessorData(channelName, postProcessorData.procDatasIDependOn{1})
           spotsChannels = [spotsChannels, channelName];
       end
    end
end

function createProcessorDataInAllObjects(...
        iterator, objProcessorRegistrar, channelArrayOfInitialProcessorData)
        
    iterator.goToFirstObject()
    while iterator.continueIteration
        try
            createProcessorDataInObject(objProcessorRegistrar, channelArrayOfInitialProcessorData)
        catch err
            fprintf('*!* Error occured at %s.\n',  iterator.getLocationDescription())
            rethrow(err)
        end
        iterator.goToNextObject()
    end    
end

function createProcessorDataInObject(objProcessorRegistrar, ...
        channelArrayOfInitialProcessorData)
    
    channelNames = channelArrayOfInitialProcessorData.channelNames;
    
    for i = 1:length(channelNames)
        channelName = channelNames{i};
        initialProcData = channelArrayOfInitialProcessorData.getByChannelName(channelName);
        objProcessorRegistrar.registerNewProcessor(initialProcData, channelName);
    end
end
