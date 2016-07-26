classdef SliceExcluderForRegionalMaxProcData < improc2.interfaces.SliceExcluder
    
    properties (Access = private)
        processorDataHolder
    end
    
    properties (Dependent = true, Access = private)
        numSlices
    end
    
    methods
        function p = SliceExcluderForRegionalMaxProcData(processorDataHolder)
            p.processorDataHolder = processorDataHolder;
        end
        function numSlices = get.numSlices(p)
            numSlices = p.processorDataHolder.processorData.imageSize(3);
        end
        function clearExclusions(p)
            p.processorDataHolder.processorData.excludedSlices = [];
        end
        function clearExclusionsAndExcludeSlicesUpTo(p, sliceNumber)
            if sliceNumber < 1;
                return;
            end
            sliceRangeToExclude = 1 : min(sliceNumber, p.numSlices);
            p.processorDataHolder.processorData.excludedSlices = ...
                sliceRangeToExclude;
            channelName = p.processorDataHoldergetChannelName();
        end
        function clearExclusionsAndExcludeSlicesStartingFrom(p, sliceNumber)
            if sliceNumber > p.numSlices;
                return;
            end
            sliceRangeToExclude = max(sliceNumber, 1) : p.numSlices;
            p.processorDataHolder.processorData.excludedSlices = ...
                sliceRangeToExclude;
            p.processorDataHolder.processorData.needsUpdate = 1;
        end
        function clearExclusionsAndIncludeOnlyBetween(p, firstIncludedSlice, lastIncludedSlice)
            assert(lastIncludedSlice >= firstIncludedSlice, 'last must be greater than first')
            slicesToExcludeAtBottom = 1 : min(firstIncludedSlice -1, p.numSlices);
            slicesToExcludeAtTop = max(lastIncludedSlice + 1, 1) : p.numSlices;
            p.processorDataHolder.processorData.excludedSlices = ...
                [slicesToExcludeAtBottom, slicesToExcludeAtTop];
            p.processorDataHolder.processorData.needsUpdate = 1;
        end 
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
        end
    end
    
end
