classdef ProcessorData < improc2.RemembersRunAndDataChange & improc2.Describeable

    properties
        reviewed = false;
    end
    properties (SetAccess = private)
        needsUpdate = false;
        % Has data that this processor depends on substantively changed, so
        % that this processor perhaps needs to be run again?
    end
    properties (SetAccess = protected)
        procDatasIDependOn = {};
        % Cell array of strings of class names of other processors that this
        % processor needs data from to run. A ProcessorManager can use
        % this information to feed appropriate data to the processor as
        % well as figure out when the data that this processor depends on
        % has changed.
        
        % The way this class is designed, any subclass is automatically
        % forced to implement a runProcessor method that takes as its
        % first arguments Processors of the classes specified in the
        % procDatasIDependOn property in the order that they appear. Otherwise
        % you will get an error.
    end
    
    methods (Access = protected)
        function pDataAfterProcessing = runProcessor(pData, varargin)
            pDataAfterProcessing = pData;
        end
    end
    
    methods
        function p = ProcessorData(description)
            if nargin == 0
                super_args = {};
            else
                super_args{1} = description;
            end
            p = p@improc2.Describeable(super_args{:});
        end
    end
    
    
    methods (Access = protected, Sealed = true)
        function dataAfterProcessing = runRemembersRun(pData, varargin)
            
            if length(varargin) < length(pData.procDatasIDependOn)
                error('improc2:BadArguments', ...
                    ['This post processor needs at least %d input processors\n',...
                    'as arguments to its run method'], length(pData.procDatasIDependOn))
            end
            
            for i = 1:length(pData.procDatasIDependOn)
                if ~isa(varargin{i}, pData.procDatasIDependOn{i})
                    errmessage = sprintf(...
                        ['The first %d argument(s) to run this post-processor ', ...
                        'must be processor(s) of type:\n%s respectively.'], ...
                        length(pData.procDatasIDependOn), strjoin(pData.procDatasIDependOn, ' AND '));
                    errdetail = sprintf(...
                        '\nGiven a *%s* at arg %d instead of an %s.', ...
                        class(varargin{i}), i, pData.procDatasIDependOn{i});
                    error('improc2:BadArguments', [errmessage, errdetail]);
                end
		if ~varargin{i}.isProcessed
		    error('improc2:DependencyNotRun', ...
		    'At least one processor necessary to run is itself unprocessed');
		end
            end
            dataAfterProcessing = runProcessor(pData, varargin{:});
        end
    end
    
    methods (Sealed = true, Hidden = true)
        function p = setNeedsUpdateFalse(p)
            p.needsUpdate = false;
        end
        function p = setNeedsUpdateTrue(p)
            p.needsUpdate = true;
        end
    end
    
end

