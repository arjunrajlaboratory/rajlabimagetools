function changeImageObjectDirPath(collection, dirPath)
    
    for i = 1:length(collection)
        objs = collection.getObjectsArray(i);
        for j = 1:length(objs)
            for nodeNumber = 1:length(objs(j).graph.nodes)
                node = objs(j).graph.nodes{nodeNumber};
                if isa(node.data, 'improc2.dataNodes.ChannelStackContainer')
                    objs(j).graph.nodes{nodeNumber}.data.dirPath = dirPath;
                end
            end
        end
        collection.setObjectsArray(objs, i);
    end
end

