classdef ImageObjectsCentroidsSource < handle
    
    properties (Access = private)
        navigator
        objectHandle
    end
    
    methods
        function p = ImageObjectsCentroidsSource(navigator, objectHandle)
           p.navigator = navigator;
           p.objectHandle = objectHandle;
        end
        
        function centroids = getCentroids(p)
            centroids = improc2.utils.getCentersOfImageObjectsInCurrentArray(...
                p.navigator, p.objectHandle);
        end
    end
end
