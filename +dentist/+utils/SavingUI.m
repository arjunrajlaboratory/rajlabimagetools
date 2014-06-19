classdef SavingUI < handle
    
    properties (Access = private)
        saveButton
        dataSaver
        saveToDiskFlag
        workingDirectory
    end
    
    methods
        function p = SavingUI(saveButton, dataSaver, saveToDiskFlag, workingDirectory)
            p.saveButton = saveButton;
            p.dataSaver = dataSaver;
            p.saveToDiskFlag = saveToDiskFlag;
            p.workingDirectory = workingDirectory;
        end
        
        function save(p)
            if p.saveToDiskFlag
                fprintf('Saving data to disk ...\n')
                p.dataSaver.save(p.workingDirectory);
                fprintf('DONE\n')
            else
                fprintf('Not saving data to disk : test mode\n')
            end
            p.setButtonToMild();
        end
        
        function setButtonToMild(p)
            set(p.saveButton, 'ForegroundColor', 'k', 'FontWeight', 'normal')
        end
        
        function setButtonToAlarm(p)
            set(p.saveButton, 'ForegroundColor', 'r', 'FontWeight', 'bold')
        end
    end
end

