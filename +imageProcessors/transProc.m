classdef transProc < imageProcessors.Processor
    properties
        middlePlane
    end

    methods

        % CONSTRUCTOR METHOD
        function p = transProc(description)
            if nargin~=0
                p.description = description;
            else
                p.description = ['get representative plane for '...
                                'Transmission / BrightField image'];
            end
        end

        function p = run(p,imgStackCropped,varargin)
        % get the middle plane of the cropped stack and use that as zMerge
        % we do not use inputs in varargin for anything, but keep so uniform with
        % other processor functions
            if nargin < 2
                fprintf(1,'Must provide input:\n');
                fprintf(1,'\trun(imgStkCropped,varargin)\n');
            else
                sz = size(imgStackCropped);
                middle = floor(sz(3)/2);
                p.middlePlane = imgStackCropped(:,:,middle);
            end
        end

        % NOTICE: there are no getNumSpots or getSpotCoordinates functions
        % defined for this Processor

        function img = getImage(p)
            if isempty(p.middlePlane)
                fprintf(1,'NOTICE: This processor has not been run yet\n');
                img = [];
            else
                img = scale(p.middlePlane);
            end
        end

        function TF = isProcessed(p)
            TF = ~isempty(p.middlePlane);   % EMPTY means has not been processed
        end
    end
end
