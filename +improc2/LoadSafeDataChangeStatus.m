classdef LoadSafeDataChangeStatus
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (SetAccess = protected)
        dataHasChanged = true(0);
        % if true, this object has changed in a significant way (one that
        % would merit rerunning dependent postprocessors, for example),
        % since the property was last set to false.
    end
    
    properties (SetAccess = private, GetAccess = private)
        dataHasChangedONDISK = true(0);
        % This attribute is only modified by saveobj and only read by
        % loadobj methods. Necessary because when MATLAB loads an object
        % from a .mat file, the reconstruction process runs 
        % property setter methods,
        % which could modify dataHasChanged. the ONDISK version is kept
        % separately so we can reset dataHasChanged to it after the loading
        % method is complete.
    end
    
    methods (Sealed = true)
        function p = setDataHasChangedToFalse(p)
            p.dataHasChanged = false(size(p.dataHasChanged));
        end
        function p = saveobj(p)
            p.dataHasChangedONDISK = p.dataHasChanged;
        end
    end
   
    methods (Static = true, Sealed = true)
        % This is sealed to prevent overriding which could happen
        % unwittingly by a developer, and it would break the load-safe
        % aspect of dataHasChanged.
        function p = loadobj(p)
            p.dataHasChanged = p.dataHasChangedONDISK;
        end
    end
    
end

