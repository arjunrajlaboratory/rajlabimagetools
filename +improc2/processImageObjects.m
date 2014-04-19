function varargout = processImageObjects(dirPathOrAnArrayCollection, overwriteFlag)
    
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    
    optionalFlags = struct();
    if nargin > 1
        if strcmp(overwriteFlag, 'overwrite')
            optionalFlags.failIfProcessorExists = false;
        end
    end
    
    imageObjectsProcessor = improc2.processing.ImageObjectsProcessor(...
        dirPathOrAnArrayCollection, optionalFlags);
    
    varargout = cell(1, nargout);
    
    if nargout == 0
        imageObjectsProcessor.displayDescriptionOfWorkToDo()
        runAsIs = queryIfUserWantsToRunProcessorAsIs();
        if runAsIs
            imageObjectsProcessor.run()
        else
            displayCustomizationUsage()
        end
    elseif nargout == 1
        varargout{1} = imageObjectsProcessor;
    end
end

function runAsIs = queryIfUserWantsToRunProcessorAsIs()
    msg = sprintf(['*!* Run as described above? (y/n) ']);
    yn = input(msg,'s');
    fprintf('\n');
    userPressedReturn = isempty(yn);
    if userPressedReturn
        yn = 'n'; 
    end
    runAsIs = any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}));
end

function displayCustomizationUsage()
    fprintf(['To customize what all is run, execute\n', ...
        '\tprocessor = improc2.processImageObjects(...);\n', ...
        'then use the methods of ''processor'' to customize it,\n',...
        'and then execute\n', ...
        '\tprocessor.run()\n'])
end
