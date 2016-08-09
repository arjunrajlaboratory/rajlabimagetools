classdef SegmentViewer < handle
    
    properties (SetAccess = private)
        displayer
        zSlicer
        imageStackDepth
    end
    
    methods
        function p = SegmentViewer(resources)
            p.build(resources)
        end
        
        function draw(p)
            p.displayer.draw()
        end
        
        function goUpOneSlice(p)
            currentSlice = p.zSlicer.sliceToTake;
            newSlice = min(currentSlice + 1, p.imageStackDepth);
            p.zSlicer.setSliceToTake(newSlice);
            p.draw()
        end
           
        function goDownOneSlice(p)
            currentSlice = p.zSlicer.sliceToTake;
            newSlice = max(currentSlice - 1, 1);
            p.zSlicer.setSliceToTake(newSlice);
            p.draw();
        end 
        
        function keyPressCallBack(p, src, event)
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

