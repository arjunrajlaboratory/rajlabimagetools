classdef DataExtractorFromAllObjects < handle
    
    properties (Access = private)
        iterator
        navigator
        objectHandleExtractor
        processorDataExtractor
        annotationDataExtractor
        objectHandle
    end
    
    methods
        function p = DataExtractorFromAllObjects(iterator, navigator, ...
                objectHandleExtractor, ...
                processorDataExtractor, annotationDataExtractor, objectHandle)
            p.iterator = iterator;
            p.navigator = navigator;
            p.objectHandleExtractor = objectHandleExtractor;
            p.processorDataExtractor = processorDataExtractor;
            p.annotationDataExtractor = annotationDataExtractor;
            p.objectHandle = objectHandle;
        end
        
        function celltableout = extractAllToCellTable(p)
            celltableout = [];
            p.iterator.goToFirstObject()
            while p.iterator.continueIteration
                extractedDataAsRow = p.extractFromThisObject();
                if isempty(celltableout)
                    celltableout = extractedDataAsRow;
                else
                    celltableout = improc2.utils.addRowToCellTable(celltableout, extractedDataAsRow);
                end
                p.iterator.goToNextObject()
            end
        end
        
        function extractAllToCSVFile(p, filename)
            celltable = p.extractAllToCellTable();
            dlmcell(filename, celltable, ',' );
        end
        
        function extractFromProcessorData(p, nameInOutput, ...
                fieldNameOrFunctionOrMethod, channelName, varargin)
            if ischar(fieldNameOrFunctionOrMethod)
                p.processorDataExtractor.setExtractField(nameInOutput, ...
                    fieldNameOrFunctionOrMethod, channelName, varargin{:})
            else
                p.processorDataExtractor.setExtractFuncOrMethod(nameInOutput, ...
                    fieldNameOrFunctionOrMethod, channelName, varargin{:})
            end
        end
        
        function extractFromObj(p, nameInOutput, functionOfObjectHandle)
            p.objectHandleExtractor.setExtractingFunction(nameInOutput, functionOfObjectHandle)
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Extractions specified:\n')
            p.annotationDataExtractor.displayExtractionSpecification();
            p.objectHandleExtractor.displayExtractionSpecification();
            p.processorDataExtractor.displayExtractionSpecification();
        end
        
        function viewObjectHandle(p)
            p.objectHandle.view();
        end
        
        function [data] = getDataFromObjectHandle(p,nodeLabel,varargin)
            data = p.objectHandle.getData(nodeLabel, varargin{:});
        end
                
        
    end
    methods (Access = private)
        function extractedDataAsRow = extractFromThisObject(p)
            objAddressData = getObjAddressData(p.navigator);
            fromAnnots = p.annotationDataExtractor.extractData();
            fromObj = p.objectHandleExtractor.extractData();
            fromProcData = p.processorDataExtractor.extractData();
            extractedData = [objAddressData; fromAnnots; fromObj; fromProcData];
            extractedDataAsRow = extractedData';
        end
    end
end

function objAddress = getObjAddressData(navigator)
    objAddress = {'objArrayNum', navigator.currentArrayNum;...
        'objNum', navigator.currentObjNum};
end

