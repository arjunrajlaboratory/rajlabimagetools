classdef ObjectHandleDataExtractor < handle
    
    properties (Access = private)
        objectHandle
        namesInOutput
        functionsOfObjectHandle
        actionDescriptions
    end
    
    methods
        function p = ObjectHandleDataExtractor(objectHandle)
            p.objectHandle = objectHandle;
            p.initializeItemsToGet();
        end
        
        function setExtractingFunction(p, nameInOutput, functionOfObjectHandle)
            if isempty(nameInOutput)
                nameInOutput = func2str(functionOfObjectHandle);
            end
            actionDescription = func2str(functionOfObjectHandle);
            p.trialExtraction(functionOfObjectHandle)
            
            p.namesInOutput = ...
                [p.namesInOutput, {nameInOutput}];
            p.actionDescriptions = ...
                [p.actionDescriptions, {actionDescription}];
            p.functionsOfObjectHandle = ...
                [p.functionsOfObjectHandle, {functionOfObjectHandle}];
            
        end      
        
        function extractedData = extractData(p)
            extractedData = cell(0,2);
            for i = 1:length(p.namesInOutput)
                nameInOutput = p.namesInOutput{i};
                functionOfObjectHandle = p.functionsOfObjectHandle{i};
                extractedDatum = functionOfObjectHandle(p.objectHandle);
                extractedData = [extractedData ; {nameInOutput, extractedDatum}];
            end
        end
        
        function displayExtractionSpecification(p)
            for i = 1:length(p.namesInOutput)
                fprintf('\tFROM object %s AS %s\n', ...
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
        function trialExtraction(p, functionOfObjectHandle)
            extractedData = functionOfObjectHandle(p.objectHandle);
            isAString = ischar(extractedData);
            isNumericScalar = isnumeric(extractedData) && isscalar(extractedData);
            isLogicalScalar = islogical(extractedData) && isscalar(extractedData);
            assert(isAString || isNumericScalar || isLogicalScalar, ...
                'Extracted value is not a string or a scalar numeric or logical')
        end
        function initializeItemsToGet(p)
            p.namesInOutput = {};
            p.functionsOfObjectHandle = {};
            p.actionDescriptions = {};
        end
    end
end

