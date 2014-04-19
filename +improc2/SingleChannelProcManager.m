classdef SingleChannelProcManager < improc2.ManagedProcQueueRunner
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        channelName = '';   
        % We have to store this in here so that this manager can run its
        % processors using only an image object as a parameter, Rather than
        % having to input an image object and the channelname every time. 
    end
    
    properties (Dependent)
        processor % the first processor
    end

    
    methods
        function p = SingleChannelProcManager(channelName, varargin)
            p = p@improc2.ManagedProcQueueRunner(varargin{:});
            if nargin > 0
                assert(ischar(channelName), 'improc2:BadArguments',...
                    'Channel name must be a string')
                p.channelName = channelName;
            else
                warning(['SingleChannelProcManager instantiated without',...
                    ' a channelName argument'])
            end
        end
                
        function p = runAllUsingImgObjHandle(p, objH)
            assert(isa(objH,'improc2.interfaces.ImageObjectHandle'),...
                'Input must be an image object handle!')
            p = p.runAllOrUpdateAll('run', objH, p.channelName);
        end
        
        function p = updateAllUsingImgObjHandle(p, objH)
            assert(isa(objH,'improc2.interfaces.ImageObjectHandle'),...
                'Input must be an image object handle!')
            p = p.runAllOrUpdateAll('update', objH, p.channelName);
        end
        
        function p = set.processor(p, proc)
            if length(p) < 1
                p = p.registerNewProcessor(proc);
            else
                % This will throw an error if you replace an existing
                % processor with one of a different class even if there is
                % only one processor. This is necessary to avoid breaking
                % multi channel post-processors that may rely on it.
                p.procstack = p.procstack.setProcessorByPos(proc, 1);
            end
        end
        
        function proc = get.processor(p)
            if length(p) < 1
                proc = [];
            else
                proc = p.procstack.getProcessorByPos(1);
            end
        end
    end
    
    methods (Access = protected)
        function p = runProcAtIndexUsingImgObjHandle(p, index, objH)
            % did not override runProcAtIndex so that we could still run
            % the processor with other types of arguments if necessary.
            assert(isa(objH,'image_object')||isa(objH,'improc2.ImageObject'),...
                'Second input must be an image object!')
            p = p.runProcAtIndex(index, objH, p.channelName);
        end
    end
end

