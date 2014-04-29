classdef DataNodeGraphTester < handle
    
    properties (Access = private)
        objectHolder
    end
    
    properties (Dependent = true)
        graph
    end
    
    methods
        function p = DataNodeGraphTester(objectHolder)
            p.objectHolder = objectHolder;
        end
        function graph = get.graph(p)
            graph = p.objectHolder.obj.graph;
        end
        
        function TF = isImmediateChild(p, parent, child)
            parentNode = getNodeByLabel(p.graph, parent);
            TF = ismember(child, parentNode.childNodeLabels);
        end
        
        function assertIsImmediateChild(p, varargin)
            assert(p.isImmediateChild(varargin{:}))
        end
        
        function data = getNodeData(p, label)
            node = getNodeByLabel(p.graph, label);
            data = node.data;
        end
        
        function assertNeedUpdate(p, varargin)
            for label = varargin
                data = p.getNodeData(label);
                assert(data.needsUpdate);
            end
        end
        
        function assertDoNotNeedUpdate(p, varargin)
            for label = varargin
                data = p.getNodeData(label{1});
                assert(~data.needsUpdate);
            end
        end
        
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p)
        end
    end
end

