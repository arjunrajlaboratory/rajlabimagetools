function chanArray = makeFilledChannelArray(channelNames, oneArgFUNC)
    chanArray = dentist.utils.ChannelArray(channelNames);
    for channelName = chanArray.channelNames
        chanArray = chanArray.setByChannelName(...
            oneArgFUNC(char(channelName)), channelName);
    end 
end

