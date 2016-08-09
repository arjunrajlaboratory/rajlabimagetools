classdef SegmentViewer < handle
    
    properties (SetAccess = private)
        displayer
        %zSlicer
        %imageStackDepth
        
    end
    
    
    properties (SetAccess = private)        
        transImage % Store the transmission image
        dapiImage % Store the dapiImage
        %rnaImage % Store the particular RNA image
        mergedImageNoObjects % store the merged image without objects for easy redrawing
        objectMasks % cell array of the masks
        
        localNavigator % local navigator
        currentObject
        currentArray
        
        
    end
    
    
    methods
        function p = SegmentViewer(resources)  % This can remain the same, most likely.
            p.build(resources)
        end
        
        function draw(p) % Probably want to redo this one completely. Maybe have the light update and major update as separate methods.
            
            p.displayer.draw()
        end
        
        function goUpOneSlice(p)  % Probably don't really need this.
            currentSlice = p.zSlicer.sliceToTake;
            newSlice = min(currentSlice + 1, p.imageStackDepth);
            p.zSlicer.setSliceToTake(newSlice);
            p.draw()
        end
        
        function goDownOneSlice(p)  % Probably don't really need this either.
            currentSlice = p.zSlicer.sliceToTake;
            newSlice = max(currentSlice - 1, 1);
            p.zSlicer.setSliceToTake(newSlice);
            p.draw();
        end
        
        function keyPressCallBack(p, src, event)  % Will want to rejigger this based on what we want keys to do.
            key = event.Key;
            if strcmp(key, 'uparrow')
                p.goUpOneSlice()
            elseif strcmp(key, 'downarrow')
                p.goDownOneSlice()
            end
        end
    end
    
    methods (Access = private)
        
        function build(p, resources)
            
            % One thing that build should do is unpack the navigator or
            % instantiate it if required. Like an "isvalid" on the
            % navigator property. Probably need a destructor to free this
            % object as well.
            
            p.localNavigator = improc2.launchImageObjectTools; % Probably
            % only need this locally in the "majorUpdate" part, so can just
            % load there? Then again, that way, it will disappear every time.
            
            p.currentObject = resources.currentObject;
            p.currentArray  = resources.currentArray;
            
            
            channelSwitcher = resources.channelSwitcher;
            viewportHolder = resources.viewportHolder;
            objectHandle = resources.objectHandle;
            axH = resources.axH;
            
            croppedStkProvider = improc2.ImageObjectCroppedStkProvider();
            zSlicer = improc2.utils.ZSlicer();
            zSlicer.setSliceToTake(1);
            
            typicalImage = croppedStkProvider.getImage(objectHandle, ...
                channelSwitcher.getChannelName);
            imageStackDepth = size(typicalImage, 3);
            
            imgSliceHolder = improc2.utils.ImageObjectScaledImageSliceHolder(...
                objectHandle, channelSwitcher, croppedStkProvider, zSlicer);
            sliceDisplayer = improc2.utils.ImageDisplayer(axH, ...
                imgSliceHolder, viewportHolder);
            
            p.displayer = sliceDisplayer;
            p.zSlicer = zSlicer;
            p.imageStackDepth = imageStackDepth;
        end
    end
end





