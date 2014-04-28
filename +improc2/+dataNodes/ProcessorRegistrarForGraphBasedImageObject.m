classdef ProcessorRegistrarForGraphBasedImageObject < improc2.interfaces.ProcessorRegistrar
    
    properties (Access = private)
        objHolder
    end
    
    properties (Access = private, Dependent = true)
        obj
    end
    
    methods
        function p = ProcessorRegistrarForGraphBasedImageObject(objHolder)
            p.objHolder = objHolder;
        end
        function obj = get.obj(p)
            obj = p.objHolder.obj;
        end
        function registerNewProcessor(p, data, channelNameOrDependencySpec)
            
        end
        function boolean = hasProcessorData(p, channelNameOrNodeName, dataClassName)
        end
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
    
end