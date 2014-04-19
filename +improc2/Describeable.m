classdef Describeable
    % An object that can print a nice description of itself.

    properties (SetAccess = 'protected')
        description = 'No short description for this.'
    end
    
    methods
        
        function p = Describeable(description)
            if nargin ~= 0
                p.description = description;
            end
        end
        
        
        function disp(p)
            fprintf(1,'Class: %s\n', class(p));
            fprintf(1,'Desc: %s\n',p.description);
            fprintf(1,'\nProperties:\n');
            p.printProperties;
            improc2.utils.displayFullMethodDescriptions(p)
%             fprintf(1,'\nMethods:\n');
%             for mName = methods(p)'
%                 fprintf(1,'\t%s\n',cell2mat(mName));
%             end
        end
            
    end
    
    methods (Access = protected)
        function printProperties(p)
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
        end
    end
end

