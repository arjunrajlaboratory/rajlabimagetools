classdef ProcessorDataExtractor < handle
    
    properties (Access = private)
        objectHandle
        namesInOutput
        functionsOfProcData
        channelsToExtractFrom
        extraArgsToGetProc
        actionDescriptions
    end
    
    methods
        function p = ProcessorDataExtractor(objectHandle)
            p.objectHandle = objectHandle;
            p.initializeItemsToGet();
        end
        
        function setExtractField(p, nameInOutput, ...
                nameOfScalarFieldInProcData, channelName, varargin)
            
            if isempty(nameInOutput)
                nameInOutput = [channelName, '.', nameOfScalarFieldInProcData];
            end
            actionDescription = ['GET ', nameOfScalarFieldInProcData];
            getterFunc = @(procData) procData.(nameOfScalarFieldInProcData);
            
            p.specifyExtractionByMethod(nameInOutput, actionDescription, ...
                getterFunc, channelName, varargin{:})
            
        end
        
        function setExtractFuncOrMethod(p, nameInOutput, ...
                functionOrMethodOfProcData, channelName, varargin)
            if isempty(nameInOutput)
                nameInOutput = [channelName, '.', func2str(functionOrMethodOfProcData)];
            end
            actionDescription = func2str(functionOrMethodOfProcData);
            p.specifyExtractionByMethod(nameInOutput, actionDescription, ...
                functionOrMethodOfProcData, channelName, varargin{:})
        end
        
        function extractedData = extractData(p)
            extractedData = cell(0,2);
            for i = 1:length(p.namesInOutput)
                nameInOutput = p.namesInOutput{i};
                functionOfProcData = p.functionsOfProcData{i};
                channelName = p.channelsToExtractFrom{i};
                extraArgsToGet = p.extraArgsToGetProc{i};
                
                procData = p.objectHandle.getData(channelName, extraArgsToGet{:});
                extractedDatum = functionOfProcData(procData);
                extractedData = [extractedData ; {nameInOutput, extractedDatum}];
            end
        end
        
        function displayExtractionSpecification(p)
            for i = 1:length(p.namesInOutput)
                fprintf('\tFROM %s %s AS %s\n', ...
                    p.channelsToExtractFrom{i}, ...
                    p.actionDescriptions{i}, ...
                    p.namesInOutput{i})
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Specified extractions:\n')
            p.displayExtractionSpecification()
        end
    end
    
    methods (Access = private)
        function specifyExtractionByMethod(p, nameInOutput, actionDescription, ...
                functionOrMethodOfProcData, channelName, varargin)
            
            p.trialExtractionFromCurrentObj(functionOrMethodOfProcData, ...
                channelName, varargin{:})
            
            p.namesInOutput = ...
                [p.namesInOutput, {nameInOutput}];
            p.actionDescriptions = ...
                [p.actionDescriptions, {actionDescription}];
            p.functionsOfProcData = ...
                [p.functionsOfProcData, {functionOrMethodOfProcData}];
            p.channelsToExtractFrom = ...
                [p.channelsToExtractFrom, {channelName}];
            p.extraArgsToGetProc = ...
                [p.extraArgsToGetProc, {varargin}];
            
        end
        function trialExtractionFromCurrentObj(p, functionOfProcData, channelName, varargin)
            procData = p.objectHandle.getData(channelName, varargin{:});
            extractedData = functionOfProcData(procData);
            isAString = ischar(extractedData);
            isNumericScalar = isnumeric(extractedData) && isscalar(extractedData);
            isLogicalScalar = islogical(extractedData) && isscalar(extractedData);
            assert(isAString || isNumericScalar || isLogicalScalar, ...
                'Extracted value is not a string or a scalar numeric or logical')
        end
        
        function initializeItemsToGet(p)
            p.namesInOutput = {};
            p.actionDescriptions = {};
            p.functionsOfProcData = {};
            p.channelsToExtractFrom = {};
            p.extraArgsToGetProc = {};
        end
    end
end

