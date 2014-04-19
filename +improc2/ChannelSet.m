classdef ChannelSet
    
    properties
        channelFields % cell array of channelNames.
        channels % struct of improc2.Channel elements
        filenames % struct
    end
    
    methods
        
        function p = ChannelSet(imagenumber, dirPath, varargin)
            p = p.buildFromFileInfo(imagenumber,dirPath);
        end
            
        function p = set.channels(p, chansin)
            % hook for subclasses to modify the inputs
            [p, chansin] = onChannelsSetting(p, chansin);
            p.channels = chansin;
        end
        
        function p = registerSingleChanProcessor(p, channelName, proc)
            p.channels.(channelName) = ...
                p.channels.(channelName).registerNewProcessor(proc);
        end
        
        function proc = getSingleChanProcByChannelByClass(p, channelName, classname, varargin)
            procstack = p.channels.(channelName).procstack;
            procindex = procstack.indexFromClassName(classname, varargin{:});
            proc = procstack.getProcessorByPos(procindex);
        end
        
        function proc = getSingleChanProcByChannelByPos(p, channelName, index)
            if nargin < 3
                index = 1;
            end
            proc = p.channels.(channelName).procstack.getProcessorByPos(index);
        end
        
        function p = runAllSingleChanProcsUsingImgObjHandle(p, objH)
            channelNameArray = fields(p.channels);
            for i = 1:length(channelNameArray)
                channelName = channelNameArray{i};
                p.channels.(channelName) = ...
                    p.channels.(channelName).runAllUsingImgObjHandle(objH);
            end
        end
        
        function p = updateAllSingleChanProcsUsingImgObjHandle(p, objH)
            channelNameArray = fields(p.channels);
            for i = 1:length(channelNameArray)
                channelName = channelNameArray{i};
                p.channels.(channelName) = ...
                    p.channels.(channelName).updateAllUsingImgObjHandle(objH);
            end
        end
    end
    
    methods (Access = protected)
        
        function p = buildFromFileInfo(p, imagenumber, dirPath)
            p.filenames.path = dirPath;
            assert( ischar(imagenumber), 'imagenumber must be a string')  ;
            % string is a image stack file number
            [p, filesadded] = p.addChannelsFromFileInfo(imagenumber, dirPath);
            p.filenames.files = filesadded;
        end
        
        function [p, filesadded] = addChannelsFromFileInfo(p, imagenumber, dirPath)
            % Create the image filename fields and .channels
            [foundChannels, ~, imgExt] = getImageFiles(dirPath, imagenumber);
            p.channelFields = foundChannels;
            filesadded = cell(size(foundChannels));
            for k = 1:length(foundChannels)
                fname = sprintf('%s%s%s',foundChannels{k},imagenumber,imgExt{k});
                p = p.addChannelFromColor(fname, foundChannels{k});
                filesadded{k} = fname;
            end
        end
        
        function p = addChannelFromColor(p, filename, channelName)
            % color should be a string
            % In future could implement defaults here. 
            p.channels.(channelName) = improc2.Channel(filename, channelName);
        end

        % Check channels for update signals
        
        function [p, chansin] = onChannelsSetting(p, chansin)
            
            channelNameArray = fields(chansin);
            for i = 1:length(channelNameArray)
                channelName = channelNameArray{i};
                chanprocs = chansin.(channelName).processors;
                dataHasChangedArray = chanprocs.dataHasChanged;
                if any(dataHasChangedArray)
                    p = p.actionOnDataChangeAtChan(channelName,dataHasChangedArray);
                    chanprocs = chanprocs.setDataHasChangedToFalse;
                    chansin.(channelName).processors = chanprocs;
                end
            end
        end
        
        function p = actionOnDataChangeAtChan(p, channelName, dataHasChangedArray);
            % Empty hook overrideable by subclasses to do something upon
            % detecting a change in a processor of a channel.
        end
        
    end
    

end


