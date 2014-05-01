classdef ThresholdQCData < NodeData

    properties
        needsUpdate = true;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.NodeData'};
        dependencyDescriptions = {'any data that has a threshold'};
    end
    properties (Access = private)
        storedHasClearThresholdStatus = improc2.TypeCheckedYesNoOrNA('NA');
    end    
    properties (Dependent = true)
        hasClearThreshold
        reviewed
    end
    methods
        function yesNoOrNA = get.hasClearThreshold(pData)
            yesNoOrNA = pData.storedHasClearThresholdStatus.value;
        end
        function pData = set.hasClearThreshold(pData, yesNoOrNA)
            pData.storedHasClearThresholdStatus.value = yesNoOrNA;
        end
        function reviewed = get.reviewed(pData)
            reviewed = pData.needsUpdate;
        end
        function pData = set.reviewed(pData, reviewed)
            pData.needsUpdate = reviewed;
        end
    end
end