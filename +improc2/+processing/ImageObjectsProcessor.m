classdef ImageObjectsProcessor < handle
    
    properties (SetAccess = private)
        availableChannels
        initialProcessorData
        imageObjectDataSource
        channelsToProcess
        failIfProcessorExists = true;
    end
    
    properties (Access = private)
        imObTools
        croppedImgProvider
    end
    
    methods
        function p = ImageObjectsProcessor(dirPathOrAnArrayCollection, optionalArgsStruct)
            
            if nargin < 2
                optionalArgsStruct = struct();
            end
            
            if isfield(optionalArgsStruct, 'failIfProcessorExists')
                p.failIfProcessorExists = optionalArgsStruct.failIfProcessorExists;
            end
            
            p.imageObjectDataSource = dirPathOrAnArrayCollection;
            p.imObTools = improc2.launchImageObjectTools(p.imageObjectDataSource);
            assert(isa(p.imObTools.objectHandle, 'improc2.ImageObjectHandle'), ...
                'This Processor only operates on improc2.ImageObjects')
            p.availableChannels = p.imObTools.objectHandle.channelNames;
            p.channelsToProcess = p.availableChannels;
            p.initialProcessorData = p.chooseProcessorDataDefaults();
            p.croppedImgProvider = improc2.utils.buildCroppedImageProvider(dirPathOrAnArrayCollection);
        end
        
        function setProcessorDataForChannel(p, procData, channelName)
            assert(isa(procData, 'improc2.procs.ProcessorData'), ...
                'improc2:BadArguments', ...
                'Processor data must be a subclass of improc2.procs.ProcessorData')
            p.initialProcessorData = ...
                p.initialProcessorData.setByChannelName(procData, channelName);
        end
        
        function setChannelsToProcess(p, channelNames)
            assert(all(ismember(channelNames, p.availableChannels)), ...
                'improc2:BadArguments', 'Some of these channels are not available')
            p.channelsToProcess = intersect(channelNames, p.availableChannels);
        end
        
        function run(p)
            fprintf('Adding unprocessed Data to all objects...\n')
            p.registerFirstProcessorDataInAllObjects()
            fprintf('Running processors...\n')
            p.runFirstProcessorsOnAllImageObjectsInSelectedChannels()
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
            fprintf('* Available channels:\n')
            fprintf('\t%s\n', strjoin(p.availableChannels, ', '))
            p.displayDescriptionOfWorkToDo()
        end
        
        function displayDescriptionOfWorkToDo(p)
            fprintf('* If run will create processed data as follows:\n')
            fprintf('\tChannel \t Processor Data Class\n')
            for i = 1:length(p.channelsToProcess)
                channelName = p.channelsToProcess{i};
                procDataToRegister = p.initialProcessorData.getByChannelName(channelName);
                fprintf('\t%s:\t %s\n', channelName, class(procDataToRegister))
            end
        end
    end
    
    methods (Access = private)
        
        function defaultProcessorDataArray = chooseProcessorDataDefaults(p)
            defaultProcessorDataArray = dentist.utils.makeFilledChannelArray(...
                p.availableChannels, @chooseProcessorDataDefaultForChannel);
        end
        
        function registerFirstProcessorDataInAllObjects(p)
            initialProcessorDataForChannelsToProcess = ...
                dentist.utils.makeFilledChannelArray(...
                p.channelsToProcess, @(x) p.initialProcessorData.getByChannelName(x));
            p.createFirstProcessorDataInAllObjects(...
                p.imObTools.objectHandle, ...
                p.imObTools.processorRegistrar, ...
                p.imObTools.iterator, ...
                initialProcessorDataForChannelsToProcess)
        end
        
        function runFirstProcessorsOnAllImageObjectsInSelectedChannels(p)
            for channelName = p.channelsToProcess
                fprintf('Processing %s channel:\n', char(channelName))
                improc2.processing.runSingleChannelProcessorOnAllImageObjects(...
                    p.imObTools.objectHandle, ...
                    p.imObTools.iterator, ...
                    p.croppedImgProvider, ...
                    char(channelName))
            end
        end
        
        function createFirstProcessorDataInAllObjects(p, ...
                objH, objProcessorRegistrar, iterator, channelArrayOfInitialProcessorData)
            
            iterator.goToFirstObject()
            while iterator.continueIteration
                try
                    p.createFirstProcessorDataInObject(objH, objProcessorRegistrar, channelArrayOfInitialProcessorData)
                catch err
                    fprintf('*!* Error occured at %s.\n',  iterator.getLocationDescription())
                    rethrow(err)
                end
                iterator.goToNextObject()
            end
        end
        
        function createFirstProcessorDataInObject(p, objH, objProcessorRegistrar, ...
                channelArrayOfInitialProcessorData)
            
            channelNames = channelArrayOfInitialProcessorData.channelNames;
            assert(all(ismember(channelNames, objH.channelNames)), 'improc2:BadArguments', ...
                'Some channels requested to process do not exist in the ImageObject')
            
            if p.failIfProcessorExists
                for channelName = channelNames
                    assert(~ objH.hasProcessorData(channelName), 'improc2:ProcExists', ...
                        'Channel: %s already has processor data registered to it', channelName{:})
                end
            end
            
            for i = 1:length(channelNames)
                channelName = channelNames{i};
                if ~objH.hasProcessorData(channelName)
                    initialProcData = channelArrayOfInitialProcessorData.getByChannelName(channelName);
                    objProcessorRegistrar.registerNewProcessor(initialProcData, channelName);
                end
            end
        end 
    end
end

function processorData = chooseProcessorDataDefaultForChannel(channelName)
    switch channelName
        case 'trans'
            processorData = improc2.procs.TransProcData();
        case 'dapi'
            processorData = improc2.procs.DapiProcData();
        otherwise
            processorData = improc2.procs.aTrousRegionalMaxProcData();
    end
end



