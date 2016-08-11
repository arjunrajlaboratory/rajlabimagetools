classdef SegmentViewer < handle
        
    properties (SetAccess = public) % Should probably use get, set routines for this to check for bounds.
        currentObject % These can be set in the controller, taken from controls.browsingTools.
        currentArray
    end
    
    
    properties (SetAccess = private)
        transImage % Store the transmission image
        dapiImage % Store the dapiImage
        %rnaImage % Store the particular RNA image
        
        
        mergedImageNoObjects % store the merged image without objects for easy redrawing
        mergedImageOnlyObjects % store the images of all objects.
        mergedImagePerimeters % store the image of the perimeters.
        
        objectCentroids % centers of the object masks.
        
        objectMasks % cell array of the masks

        axH
        
        
    end
    
    
    methods
        function p = SegmentViewer(resources)  % This can remain the same, most likely.
            p.build(resources)
        end
        
        function draw(p) % Probably want to redo this one completely. Maybe have the light update and major update as separate methods.

            mergedObjectImage = makeColoredImage(p.objectMasks{p.currentObject},[0.1 0.2 0.1]) + ...
                                makeColoredImage(p.mergedImageOnlyObjects,[0 0 0.1]) + ...
                                makeColoredImage(p.mergedImagePerimeters,[0 1 0]);
            
            imshow(mergedObjectImage + im2double(p.mergedImageNoObjects),'Parent',p.axH);
            set(p.axH,'YDir','Normal')
            for i = 1:numel(p.objectMasks) % Draw the object numbers on top.
                text(p.objectCentroids(i,1),p.objectCentroids(i,2),num2str(i),'Color','white','Fontsize',14,'Parent',p.axH)
            end

        end
        
        function arrayUpdate(p) % This is the "major" update. Could also just make this an "update data" and then have a single draw function.
            localTools = improc2.launchImageObjectTools;
            localTools.navigator.tryToGoToArray(p.currentArray);
            testObjectHandle = localTools.objectHandle;
            
            p.objectMasks = {};
            p.objectCentroids = zeros(0,2); % Get masks and centroids
            for i = 1:localTools.navigator.numberOfObjectsInCurrentArray
                localTools.navigator.tryToGoToObj(i);
                objectHandle = localTools.objectHandle;
                p.objectMasks{i} = objectHandle.getMask;
                CC = bwconncomp(p.objectMasks{i});
                S = regionprops(CC,'Centroid');
                p.objectCentroids = [p.objectCentroids; S.Centroid];
            end
            
            
            p.mergedImageOnlyObjects = false(size(p.objectMasks{1})); % Allocate array of appropriate size
            p.mergedImagePerimeters  = false(size(p.objectMasks{1})); % Allocate array of appropriate size
            for i = 1:localTools.navigator.numberOfObjectsInCurrentArray
                p.mergedImageOnlyObjects = p.mergedImageOnlyObjects | p.objectMasks{i};
                p.mergedImagePerimeters = p.mergedImagePerimeters | bwperim(p.objectMasks{i});
            end
            
            channelNames = testObjectHandle.channelNames;
            stackProvider = improc2.ImageObjectFullStkProvider;
            
            if sum(strcmp('trans',channelNames))
                p.transImage = stackProvider.getImage(testObjectHandle,'trans');
                sz = size(p.transImage);
                p.transImage = scale(p.transImage(:,:,round((sz(3)+1)/2)));
            else
                p.transImage = [];
            end
            
            if sum(strcmp('dapi',channelNames))
                p.dapiImage = stackProvider.getImage(testObjectHandle,'dapi');
                p.dapiImage = scale(max(p.dapiImage,[],3));
            else
                p.dapiImage = [];
            end
            
            p.mergedImageNoObjects = cat(3,p.transImage*0.5 + p.dapiImage*0.2,p.transImage*0.5,p.transImage*0.5 + p.dapiImage*0.7);
            
        end

    end
    
    methods (Access = private)
        
        function build(p, resources)
            p.currentObject = resources.currentObject;
            p.currentArray  = resources.currentArray;
            p.axH = resources.axH;
        end
    end
end





