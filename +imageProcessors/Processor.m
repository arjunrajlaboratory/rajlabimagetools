%% +imageProcessors.Processor
% Base class to be subclassed by more specific image processor applications

classdef Processor

    properties
        description  % (str) short description of what the processor does
        reviewed = false; % whether the results have been manually reviewed
        metadata
    end

    methods

        % CONSTRUCTOR METHOD
        function p = Processor(description)
            if nargin~=0  % required for subclassing
                p.description = 'This is the base class for image processors';
            end
        end

        function disp(p)
            fprintf(1,'Desc: %s\n',p.description);
            fprintf(1,'\nProperties:\n');
            for pName = properties(p)'
                if strcmp('description',cell2mat(pName)); continue; end;
                fprintf(1,'\t%s: ',cell2mat(pName))
                val = p.(cell2mat(pName));
                if isempty(val)
                    fprintf(1,'[]\n');
                elseif isstruct(val)
                    fprintf(1,'[struct]\n');
                elseif isnumeric(val)
                    if all(size(val) == 1)
                        fprintf(1,'%.2f\n',val);
                    else
                        fprintf(1,'[');
                        sz = size(val);
                        for s = 1:numel(sz)-1
                            fprintf(1,'%dx',sz(s));
                        end
                        fprintf(1,'%d %s]\n',sz(end),class(val));
                    end
                elseif islogical(val)
                    if val; fprintf(1,'true\n'); else fprintf(1,'false\n');end;
                else 
                    fprintf(1,'%s\n',class(val));
                end
            end
            fprintf(1,'\nMethods:\n');
            for mName = methods(p)'
                fprintf(1,'\t%s\n',cell2mat(mName))
            end
        end

        function p = run(p,imgStackCropped,imgObjMask)
        % results are in the form of the modified Processor, with results
        % parameters stored in the property fields
            fprintf(1,'NOTICE: method is not defined for this processor\n');
        end
        function numSpots = getNumSpots(p)
            fprintf(1,'NOTICE: getNumSpots is not defined for this processor\n');
            numSpots = [];
        end
        function [I,J,K] = getSpotCoordinates(p)
            fprintf(1,'NOTICE: getSpotCoordinates is not defined for this processor\n');
            I = []; J = []; K = [];
        end

        function img = getImage(p)
        % Different processors have different ways of creating their 
        % representative 2D image from the original, processed 3D image stack
            fprintf(1,'NOTICE: getImage is not defined for this processor\n');
            img = [];
        end

        function [imgH] = plotImage(p,axH)
        % plot the processed image
            if nargin ~= 2
                hFig = figure; axH = axes('Parent',hFig);
            end
            if ~ishandle(axH) || ~strcmp('axes',get(axH,'Type'))
                error('Must provide an axes handle for plotting');
            elseif isempty(p.getImage)
                error('Procesor has not been run yet');
            end
            imgH = imshow(p.getImage,'Parent',axH);
        end

        function TF = isProcessed(p)
            fprintf(1,'NOTICE: method has not been defined for this processor\n');
            TF = [];
        end
    end
            
end
