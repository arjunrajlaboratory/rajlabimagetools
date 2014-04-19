classdef ImageObjectAnnotationsHolder < handle
    %UNTITLED77 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        imObHolder
    end
    
    properties (Dependent = true)
        annotations
    end
    
    methods 
        function p = ImageObjectAnnotationsHolder(imObHolder)
            p.imObHolder = imObHolder;
        end 
        
        function annotStruct = get.annotations(p)
            annotStruct = p.imObHolder.obj.annotations;
        end
        
        function set.annotations(p, annotStruct)
            p.imObHolder.obj.annotations = annotStruct;
        end
    end
end

