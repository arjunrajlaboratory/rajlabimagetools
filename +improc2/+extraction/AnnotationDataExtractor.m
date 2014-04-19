classdef AnnotationDataExtractor < handle
    
    properties (Access = private)
        namedValues
    end
    
    methods
        function p = AnnotationDataExtractor(namedValues)
            p.namedValues = namedValues;
        end
        
        function displayExtractionSpecification(p)
            fprintf('\textract all annotations\n')
        end
        
        function extractedData = extractData(p)
            
            extractedData = cell(0,2);
            
            itemNames = p.namedValues.itemNames;
            itemClasses = p.namedValues.itemClasses;
            
            for i = 1:length(itemNames)
                itemName = itemNames{i};
                itemClass = itemClasses{i};
                itemValue = p.namedValues.getValue(itemName);
                valueAsString = improc2.utils.convertValueToString(...
                    itemValue, itemClass);
                extractedData = [extractedData ; {itemName, valueAsString}];
            end 
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
            fprintf('* Specified extractions:\n')
            p.displayExtractionSpecification()
        end
    end
end

