function RenameFiles
    warning off;
    numChannels = input('Enter the number of channels: ');
    
    yn = input('Would you like to navigate to another directory (y/n) [n]? ','s');
    
    if isempty(yn) yn = 'n'; end
    if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
        dirPath = uigetdir(pwd,'Navigate to image files');
    else
        dirPath = pwd;
    end
    display('Getting directory contents ...');
    files = dir(dirPath);
    display(' ');
    % Error stores the errors that were found
    % 1 --> Multiple instances of w# in same filename
    % 2 --> Multiple s# tokens
    % 3 --> Missing file number
    % 4 --> Multiple of file number
    errors = [];
    % channels contains N cells (N is # of found channels).  In each cell
    % is the fileNums that were found
    channels = [];
    for index = 1:numel(files)
        fileNum = [];
        chanNum = [];
        
        name = files(index).name;
        % Continue if not a tiff file
        startInds = regexpi(name,'.tif|.TIF|.TIFF|.tiff');
        if isempty(startInds)
            continue;
        end
        % Find w# token (indicates channel)
        [startInds,endInds] = regexpi(name,'w(\d+)');
        if numel(startInds) > 1
            display(strcat('File: ',name,' contains multiple ''w'' tokens'));
            errors = [errors,1];
        elseif numel(startInds) == 0
            display(strcat('File: ',name,' contains no ''w'' tokens'));
        else
            chanNum = str2num(name((startInds(1) + 1):endInds(1)));
        end
        % Find s# token (indicates fileNum)
        [startInds2,endInds2] = regexpi(name,'_s(\d+)');
        if numel(startInds2) > 1
            display(strcat('File: ',name,' contains multiple ''_s#'' tokens'));
            errors = [errors,2];
        elseif numel(startInds2) == 0
            display(strcat('File: ',name,' contains no ''_s#'' tokens'));
        else
            fileNum = str2num(name((startInds2(1) + 2):endInds2(1)));
        end
        if ~isempty(fileNum) && ~isempty(chanNum)
            % Increase size of channels vector if necessary
            if numel(channels) < chanNum
                for index = 1:(chanNum - numel(channels))
                    channels = [channels,{[]}];
                end
            end
            mat = cell2mat(channels(chanNum));
            mat = [mat,fileNum];
            channels(chanNum) = {mat};
        end
    end
    numFiles = [];
    % Go through each channel and find if contiguous
    for chanIndex = 1:numel(channels)
        vector = cell2mat(channels(chanIndex));
        for fileNum = min(vector):max(vector)
            inds = find(vector == fileNum);
            if numel(inds) == 0
                display(strcat('Missing file number: ',int2str(fileNum),' for channel w',int2str(chanIndex)));
                errors = [errors,3];
            elseif numel(inds) > 1
                display(strcat('Multiple of file number: ',int2str(fileNum),' for channel w',int2str(chanIndex))); 
                errors = [errors,4];
            end
        end
        numFiles = [numFiles;numel(vector)];
    end
    display(' ');
    prevNum = [];
    % Output number of files in each channel
    for chanIndex = 1:size(numFiles,1)
        if ~isempty(prevNum) && prevNum ~= numFiles(chanIndex,1)
            errors = [errors,6];
        end
        display(strcat(int2str(numFiles(chanIndex,1)),' files in channel w',int2str(chanIndex)));
        prevNum = numFiles(chanIndex,1);
    end

    if numel(channels) ~= numChannels
        errors = [errors,5];
    end
    % Error stores the errors that were found
    % 1 --> Multiple instances of w# in same filename
    % 2 --> Multiple s# tokens
    % 3 --> Missing file number
    % 4 --> Multiple of file number
    % 5 --> Number of found channels does not match inputted number
    % 6 --> Inconsistent numbers of files across channels
    display(' ');
    newNames = [];
    if ~isempty(errors)
        display('ERRORS - PROGRAM WILL NOT CONTINUE: ');
        if ~isempty(find(errors == 1))
            display('Multiple instances of ''w#'' token in same filename');
        end
        if ~isempty(find(errors == 2))
            display('Multiple instance of ''s#'' token in same filename');
        end
        if ~isempty(find(errors == 3))
            display('Missing file number');
        end
        if ~isempty(find(errors == 4))
            display('Multiple of same file number');
        end
        if ~isempty(find(errors == 5))
            display('Number of found channels does not match entered number');
        end
        if ~isempty(find(errors == 6))
            display('Inconsistent numbers of files across channels');
        end
    else % Continue program
        for chanIndex = 1:numel(channels)
            name = input(strcat('Enter channel name for w',int2str(chanIndex),': '),'s');
            name(name == ' ') = [];
            newNames = [newNames;{name}];
        end
        display(' ');
        for chanIndex = 1:numel(channels)
           display(strcat('w',int2str(chanIndex),' --> ',cell2mat(newNames(chanIndex)))); 
        end
        display(' ');
        % Cycle through the names and make sure they match channel names
        dictionary = {'alexa','cy','gfp','nir','tmr','dapi'};
        noMatch = [];
        for index = 1:numel(newNames)
            match = false;
            for inner = 1:numel(dictionary)
                if strcmp(cell2mat(newNames(index)),cell2mat(dictionary(inner)))
                    match = true; 
                end
            end
            if ~match
                noMatch = [noMatch,newNames(index)];
            end     
        end
        if ~isempty(noMatch)
            display('No matching channel name in dictionary for: ');
            for index = 1:numel(noMatch)
               display(cell2mat(noMatch(index))); 
            end
            display(' ');
        end
        
        yn = input('Would you like to continue with renaming? ','s');

        if isempty(yn) yn = 'n'; end
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))

        else
            return;
        end

        command = [strcat('perl(''Rename.pl''',',''',dirPath,'''')];

        args = [];
        argIndex = 1;
        for chanIndex = 1:numel(channels)
            command = strcat(command,',''w',int2str(chanIndex),''',''',cell2mat(newNames(chanIndex)),'''');
        end
        command = strcat(command,');');
        display(command);
        display('Renaming files . . .');
        
        eval(command);
        display('Renaming Complete');
    end
end