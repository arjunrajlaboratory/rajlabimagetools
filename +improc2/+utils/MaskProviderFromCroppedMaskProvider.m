classdef MaskProviderFromCroppedMaskProvider < handle
    
    properties (Access = private)
        croppedMaskProvider
    end
    
    methods
        function p = MaskProviderFromCroppedMaskProvider(croppedMaskProvider)
            p.croppedMaskProvider = croppedMaskProvider;
        end
        function mask = getMask(p)
            mask = p.croppedMaskProvider.getCroppedMask();
        end
    end
    
end

