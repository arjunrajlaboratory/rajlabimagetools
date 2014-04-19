classdef SpotFrequencyTable
    properties (GetAccess = private, SetAccess = private)
        frequencyTable
    end
    
    properties (Dependent = true)
        values
        frequencies
    end
    
    methods
        function p = SpotFrequencyTable(values)
            p = p.addSpotIntensityValues(values);
        end
        function values = get.values(p)
            values = p.frequencyTable(:,1);
        end
        function frequencies = get.frequencies(p)
            frequencies = p.frequencyTable(:,2);
        end 
        function p = addSpotIntensityValues(p, values)
            % Reduce the precision of the values by 2 decimal places
            % This saves on memory
            values = round(values * 100);
            values = values/100;
            table = tabulate(values);
            % 3rd column gives frequency in percentage which isn't needed
            table = table(:,1:2);
            if isempty(p.frequencyTable)
                p.frequencyTable = table;
            else
                p.frequencyTable = combineFrequencyTables(p.frequencyTable, table);
            end
        end
        function p = add(p, q)
            if isempty(p.frequencyTable)
                p = q;
            else
                p.frequencyTable = combineFrequencyTables(...
                    p.frequencyTable, [q.values q.frequencies]);
            end
            
        end
    end
end
function table1 = combineFrequencyTables(table1, table2)
    commonElementsMaskT1 = ismember(table1(:,1),table2(:,1));
    commonElementsMaskT2 = ismember(table2(:,1),table1(:,1));
    table1(commonElementsMaskT1,2) = table1(commonElementsMaskT1,2) +...
        table2(commonElementsMaskT2,2);
    newElementsMask = ~ismember(table2(:,1),table1(:,1));
    addSubset = table2(newElementsMask,1:2);
    table1 = [table1; addSubset];
    % sort table by first colummn
    table1 = sortrows(table1,1);
end


