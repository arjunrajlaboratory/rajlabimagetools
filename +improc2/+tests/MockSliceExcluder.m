classdef MockSliceExcluder < improc2.interfaces.SliceExcluder
    
    methods
        function clearExclusions(p)
            fprintf('requested clear all exclusions');
        end
        function clearExclusionsAndExcludeSlicesUpTo(p, sliceNumber)
            fprintf('requested exclude up to %d\n', sliceNumber)
        end
        function clearExclusionsAndExcludeSlicesStartingFrom(p, sliceNumber)
            fprintf('requested exclude starting from %d\n', sliceNumber)
        end
        function clearExclusionsAndIncludeOnlyBetween(p, firstIncludedSlice, lastIncludedSlice)
            fprintf('requested include only between %d and %d\n', ...
                firstIncludedSlice, lastIncludedSlice)
        end 
    end
end

