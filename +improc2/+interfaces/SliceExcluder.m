classdef SliceExcluder < handle
    
    properties
    end
    
    methods (Abstract = true)
        clearExclusions(p)
        clearExclusionsAndExcludeSlicesUpTo(p, sliceNumber)
        clearExclusionsAndExcludeSlicesStartingFrom(p, sliceNumber)
        clearExclusionsAndIncludeOnlyBetween(p, firstIncludedSlice, lastIncludedSlice)
    end
    
end

