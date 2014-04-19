classdef AnnotationsHolderForLegacyimage_object < handle
    %UNTITLED75 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (Dependent = true)
        annotations
    end
    
    methods
        function p = AnnotationsHolderForLegacyimage_object(imObHolder)
            p.imObHolder = imObHolder;
        end
        
        function annotStruct = get.annotations(p)
            annotStruct = struct();
            annotStruct.isGood = ...
                improc2.TypeCheckedLogical(logical(p.imObHolder.obj.isGood));
            if isfield(p.imObHolder.obj.metadata, 'annotations')
                annotStruct = mergeStructs(p.imObHolder.obj.metadata.annotations, annotStruct);
            end
        end
        
        function set.annotations(p, annotStruct)
            if isfield(annotStruct, 'isGood')
                p.imObHolder.obj.isGood = annotStruct.isGood.value;
                annotStruct = rmfield(annotStruct, 'isGood');
            end
            p.imObHolder.obj.metadata.annotations = annotStruct;
        end
    end
    
end

function out = mergeStructs(in1, in2)
    out = in2;
    fieldsToAdd = fields(in1);
    for i = 1:length(fieldsToAdd)
        fieldName = fieldsToAdd{i};
        out.(fieldName) = in1.(fieldName);
    end 
end
