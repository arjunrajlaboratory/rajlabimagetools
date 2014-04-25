classdef ProcessorDataGraph
    
    properties
        tableRows = {};
        channelNames;
        vertices = {};
        vertexNumbersOfRawImageDependents = struct();
    end
    
    methods
        function p = ProcessorDataGraph(channelNames)
            p.channelNames = channelNames;
            for channelName = p.channelNames
                p.vertexNumbersOfRawImageDependents.(channelName{1}) = [];
            end
        end
        function p = addVertex(p, newVertex)
            assert(all(ismember(newVertex.channelNamesOfRawImageDependencies, ...
                p.channelNames)))
            
            newVertex.number = length(p.vertices) + 1;
            newVertex.vertexNumbersOfDependents = [];
            
            p.vertices = [p.vertices, {newVertex}];
            
            for i = 1:length(newVertex.vertexNumbersOfDependencies)
                dependencyVertexNumber = newVertex.vertexNumbersOfDependencies(i);
                p.vertices{dependencyVertexNumber}.vertexNumbersOfDependents(end + 1) = ...
                    newVertex.number;
            end
            
            for channelName = newVertex.channelNamesOfRawImageDependencies
                p.vertexNumbersOfRawImageDependents.(channelName{1})(end + 1) = ...
                    newVertex.number;
            end
        end
    end
end

