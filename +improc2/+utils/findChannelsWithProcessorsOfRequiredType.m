function channelNames = findChannelsWithProcessorsOfRequiredType(...
        imageObjectHandle, processorClassName)
    channelCandidates = imageObjectHandle.channelNames;
    channelNames = {};
    for i = 1:length(channelCandidates)
        channelName = channelCandidates{i};
        if imageObjectHandle.hasData(channelName, ...
                processorClassName)
            channelNames = [channelNames {channelName}];
        end
    end
end
