classdef ThresholdReviewFlagger < handle
    
    properties (Access = private)
        processorDataHolder
    end
    
    methods
        function p = ThresholdReviewFlagger(processorDataHolder)
            p.processorDataHolder = processorDataHolder;
        end
        
        function flagThresholdAsReviewed(p)
            p.processorDataHolder.processorData.reviewed = true;
        end
    end 
end

