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
            % updateZmerge(channelStkContainer, slices)

        end
        function clearExclusionsAndExcludeSlicesStartingFrom(p, sliceNumber)
            if sliceNumber > p.numSlices;
                return;
            end
            sliceRangeToExclude = max(sliceNumber, 1) : p.numSlices;
            p.processorDataHolder.processorData.excludedSlices = ...
                sliceRangeToExclude;
        end
        function clearExclusionsAndIncludeOnlyBetween(p, firstIncludedSlice, lastIncludedSlice)
            assert(lastIncludedSlice >= firstIncludedSlice, 'last must be greater than first')
            slicesToExcludeAtBottom = 1 : min(firstIncludedSlice -1, p.numSlices);
            slicesToExcludeAtTop = max(lastIncludedSlice + 1, 1) : p.numSlices;
            p.processorDataHolder.processorData.excludedSlices = ...
                [slicesToExcludeAtBottom, slicesToExcludeAtTop];
        end 
        function disp(p)
            improc2.utils.displayDescriptionOfHandleObject(p);
        end
        function p = updateZmergeAfterSliceExclusion(p)
            % get channelStkContainer
            
            
            % get range of included slices
            exSlices = p.processorDataHolder.processorData.excludedSlices;
            totalRange = 1:size(channelStkContainer.croppedImg, 3);
            incSlices = ~ismember(exSlices, totalRange);
            
            % filter the stack and exclude slices
            img = channelStkContainer.croppedImage;
            
            filteredImg = p.processorDataHolder.imageFilterFunc(img, p.processorDataHolder.filterParams);
            
            filteredImg = filteredImg(:,:,incSlices);
            
            % set zMerge
            p = p.set.zMerge(max(filteredImg,[],3));
            
        end
    end
    
end
