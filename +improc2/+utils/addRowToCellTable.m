function [ outtable ] = addRowToCellTable( existingtable, inputrow )
% Adds a row to a cell array by matching column names 

% existingtable:    A cell array with N+1 rows. N>0. 
% The first row is strings containing the
% column names. The following rows contain values.

% inputrow: A cell array of exactly two rows. The first row contains column
% names. The second contains values. The column names do not need to be the
% same as in existingtable

% outtable: A cell array with N+2 rows. New columns are attached if there
% are columns in input row that were not in existingtable. These are filled
% in with empty values of the same class as in the inputrow. The inputrow
% data is attached as the last row. Values corresponding to columns not
% found in inputrow but in existingtable are also filled in as empty of the
% appropriate class.

    
    
    
    
colNamesInExisting = existingtable(1,:);
colNamesInInput = inputrow(1,:);

newrow = cell(1,size(existingtable,2));
for colnum = 1:size(existingtable,2)
    colName = existingtable{1,colnum};
    colnumInInput = find(strcmp(colName,colNamesInInput));
    if (isempty(colnumInInput))
        columnclass = class( existingtable{2,colnum} );
        eval(['newrow{colnum}=',columnclass,'.empty;']);
    else
        newrow{colnum} = inputrow{2,colnumInInput(1)};
    end
end

outtable = existingtable;
for colnumInInput = find(~ismember(colNamesInInput,colNamesInExisting));
    colName = inputrow{1,colnumInInput};
    colnum = colnum + 1;
    newcoldata = cell(size(existingtable,1)-1,1);
    columnclass = class( inputrow{2,colnumInInput} );
    emptyval = eval([columnclass,'.empty']);
    for i = 1:length(newcoldata)
        newcoldata{i} = emptyval;
    end
    newcoldata = [inputrow(1,colnumInInput); newcoldata ];
    outtable = [outtable,  newcoldata];
    newrow = [newrow, inputrow(2,colnumInInput)];
end
    
outtable = [outtable ; newrow];
    

end

