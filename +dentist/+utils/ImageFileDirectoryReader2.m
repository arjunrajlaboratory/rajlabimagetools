classdef ImageFileDirectoryReader2 < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        dirPath;
        availableChannels;
        Nrows;
        Ncols;
        imgExts;
        fileNums;
    end
    
    properties (SetAccess = private, GetAccess = public)
        filePathsGrid;
    end
    
    properties (Dependent = true)
        availableFishChannels
    end
    
    methods
        function p = ImageFileDirectoryReader2(dirPath)
            if nargin < 1
                p.dirPath = pwd;
            else
                p.dirPath = dirPath;
            end
            p.readImageFileDirectory();
        end
        
        function implementGridLayout(p, Nrows, Ncols, ...
                nextFileDirection, secondaryDirection, snakeOrNoSnake)
            assert(Nrows > 1 && Ncols > 1 && (Nrows * Ncols) <= length(p.fileNums), ...
                'Invalid range for dimensions');
            p.Nrows = Nrows;
            p.Ncols = Ncols;
            nameExt = p.imgExts{1};
            p.filePathsGrid = dentist.utils.buildFilePathsGrid(p.dirPath, nameExt, ...
                p.availableChannels, p.Nrows, p.Ncols, ...
                nextFileDirection, secondaryDirection, snakeOrNoSnake);
        end
        
        function filePath = getFilePathByChannelByPosition(p, channelName, varargin)
            [row, col] = dentist.utils.asRowAndColumn(varargin{:});
            channelIndex = strcmp(channelName, p.availableChannels);
            filePath = p.filePathsGrid{row, col, channelIndex};
        end
        
        function fishChannels = get.availableFishChannels(p)
            fishChannels = p.availableChannels(ismember(p.availableChannels, {'alexa','cy','tmr','nir'}));
        end
    end
    
    methods (Access = private)
        function readImageFileDirectory(p)
            [p.availableChannels,p.fileNums,p.imgExts] = dentist.utils.getImageFiles(p.dirPath);
            if isempty(p.fileNums)
                fprintf(1,'Could not find any image files!\n');
                yn = input('Navigate to the directory with your files? y/n [y]','s');
                if isempty(yn); yn = 'y'; end;  % default answer when press return only
                if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
                    p.dirPath = uigetdir(pwd,'Navigate to image files');
                    if p.dirPath == 0;  % User pressed cancel
                        return;
                    end
                    [p.availableChannels,p.fileNums,p.imgExts] = dentist.utils.getImageFiles(p.dirPath);
                    if isempty(p.fileNums)
                        error('Could not find image files (eg ''tmr001.tif'' etc) to segment');
                    end
                else
                    return;  % user did not want to navigate to image files, quit GUI
                end
            end
        end
    end
    
end

