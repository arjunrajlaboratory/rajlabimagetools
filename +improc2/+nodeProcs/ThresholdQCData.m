classdef ThresholdQCData < improc2.interfaces.NodeData

    properties
        needsUpdate = true;
    end
    properties (Constant = true)
        dependencyClassNames = {'improc2.interfaces.NodeData'};
        dependencyDescriptions = {'any data that has a threshold'};
    end
    properties (Access = private)
        storedHasClearThresholdStatus
    end    
    properties (Dependent = true)
        hasClearThreshold
        reviewed
    end
    methods
        function nData = ThresholdQCData()
            nData.storedHasClearThresholdStatus = improc2.TypeCheckedYesNoOrNA('NA');
        end
        function yesNoOrNA = get.hasClearThreshold(nData)
            yesNoOrNA = nData.storedHasClearThresholdStatus.value;
        end
        function nData = set.hasClearThreshold(nData, yesNoOrNA)
            nData.storedHasClearThresholdStatus.value = yesNoOrNA;
        end
        function reviewed = get.reviewed(nData)
            reviewed = ~ nData.needsUpdate;
        end
        function nData = set.reviewed(nData, reviewed)
            nData.needsUpdate = ~ reviewed;
        end
    end
end