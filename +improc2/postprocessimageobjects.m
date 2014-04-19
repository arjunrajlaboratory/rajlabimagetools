%% postprocessimageobjects
% Allows for post processing of spot information after objects have been
% thresholded

%% Description
% Find all |data*.mat| files that contain the segmented and processed
% |image_objects|, set and run post processing routines.

%% Input
% _Optional_ (uses *'param','value'* paired input style)
%
% * *|verbose|* - see the visual results (spots on images) of processing 
%
% * *|directory|* - specify the location of the |data*.mat| files
%
% * *|fileNums|* - number sequence that specifies desired |data*.mat| to be processed 
% 
% * *|channels|* - specify a subset of channels (e.g. {'alexa','tmr'}) to process
%
% * *|imageProcessors|* - 
%
% * *|channelTypes|* - 
%
% * *|descriptions|* - 

%% Example Usage
% *Most simple/common usage case*
%  >> SegmentGUI  % segment your images
%  >> processimageobjects2  % filter, find regional maxima, auto-threshold
%  >> ThresholdGUI  % manually review thresholds for spot identification
%  >> postprocessimageobjects
%  >> load data001
%  >> objects(1).channels.tmr.plotImage  % see the results of processing 
%
% *

%% Authors
% Arjun Raj 2012
%
% Marshall J. Levesque 2012

function postprocessimageobjects(varargin)
    
    %------------------------------------------------------------------
    % Input parsing and setup
    %------------------------------------------------------------------
    p = inputParser;
    p.addOptional('GUI',true,@islogical);
    p.addOptional('verbose',false,@islogical);
    p.addOptional('directory',pwd,@isstr);
    p.addOptional('fileNums',[],@isnumeric);
    p.addOptional('channels',{},@iscell);
    p.addOptional('imageProcessors',{},@iscell);
    p.addOptional('channelTypes',{},@iscell);
    p.addOptional('descriptions',{},@iscell);
    p.parse(varargin{:});
    GUI = p.Results.GUI;
    dirPath = p.Results.directory;
    imageProcessors = p.Results.imageProcessors;
    channelsToProcess = p.Results.channels;
    descriptions = p.Results.descriptions;
    channelTypes = p.Results.channelTypes;
    filesToProcess = p.Results.fileNums;
    verboseFlag = p.Results.verbose;


    %------------------------------------------------------------------
    % Retreive and check the input 'data***.mat' and image files 
    %------------------------------------------------------------------
    % Start by checking for the 'data***.mat' files from segmentation
    % that store |image_object|. Will use to get segmentation ROIs and 
    % store the image processing results. 
    [dataFiles,dataNums] = getDataFiles(dirPath);

    % Also look for image files in the current working directory.
    [foundChannels,imgNums,imgExt] = getImageFiles(dirPath);

    % make sure that if we have both data & image files, that the numbering
    % scheme makes some sense. For example, if we have 'data001-data010.mat'
    % files then there should also be 'tmr001-tmr010.tif' and not less.
    if isempty(dataNums) || isempty(imgNums)
        fprintf(1,'Could not find data and/or image files!\n');
        yn = input('Navigate to the directory with your files? y/n [y]','s');
        if isempty(yn); yn = 'y'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            dirPath = uigetdir(pwd,'Navigate to data & image files');
            if dirPath == 0;  % User pressed cancel 
                return;  % quit the GUI
            end
            [dataFiles,dataNums] = getDataFiles(dirPath);
            [foundChannels,imgNums,imgExt] = getImageFiles(dirPath);

            if isempty(dataNums) || isempty(imgNums)
                error('Could not find data and/or image files in this directory');
            end
        else
            return;  % user did not want to navigate to data/image files, quit
        end
    end
    
    
    % The logic is as follows: if GUI is true (default), then run the GUI.
    % The GUI will have a "GO" button.  Clicking GO will give then call
    % postprocessimageobjects.m with GUI set to false (and all processing inputs
    % specified).
    if GUI
        PostProcessDataGUI(dirPath,dataFiles,dataNums);
        return;
    end

    if ~isempty(filesToProcess)  % User specified a subset of files to process
        [matchingNums,matchingInds] = intersect(dataNums,filesToProcess);
        if isempty(matchingNums) || numel(matchingNums) ~= numel(filesToProcess)
            msg = 'Specified file numbers do not match the found data files\n';
            msg = [msg 'Found data files:\t' sprintf('%d ',dataNums) '\n'];
            msg = [msg 'Specified data files:\t' sprintf('%d ',filesToProcess)];
            error(sprintf(msg));
        else
            dataFiles = dataFiles(matchingInds);
            dataNums = dataNums(matchingInds);
            imgNums = imgNums(matchingInds);
            fprintf(1,['Specified data files:\t' sprintf('%d ',dataNums) '\n']);
        end
    end

    if ~all(dataNums == imgNums)
        msg = sprintf(['Numbering of data*.mat files does not match image files\n'...
                       'This should not happen']);
        error(sprintf(msg));
    end

    channelOrder = []; % checked whether input has corresponding channels with options
    if ~isempty(channelsToProcess)  % User specified a subset of channels to process
        [matchingChannels,matchingInds] = intersect(foundChannels,channelsToProcess);
        if isempty(matchingChannels) || ...
                        numel(matchingChannels) ~= numel(channelsToProcess)
            msg = 'Specified channels do not match the image filenames\n';
            msg = [msg 'Found image files:\t' ...
                            sprintf('%s ',foundChannels) '\n'];
            msg = [msg 'Specified channels:\t' sprintf('%s ',channelsToProcess{:})];
            error(sprintf(msg));
        else
            foundChannels = foundChannels(matchingInds);
            fprintf(1,['Specified image channels:\t' ...
                            sprintf('%s ',foundChannels{:}) '\n' ]);
            imgExt = imgExt(matchingInds);
            [matchingChannels,channelOrder] = ...
                    intersect(channelsToProcess,matchingChannels);
        end
    end  % else, use the |foundChannels| from getImageFiles()

    if ~isempty(channelTypes)  % user specified channel types
        if numel(foundChannels) ~= numel(channelTypes)
            msg = 'Need corresponding channels & channel types\n';
            msg = [msg 'Specified channels:\t' sprintf('%s ',foundChannels{:}) '\n'];
            msg = [msg '\nSpecified channelTypes:\t' sprintf('%s ',channelTypes{:})];
            error(sprintf(msg));
        elseif isempty(channelOrder)
            error('Must specify corresponding channels with channelTypes')
        else
            channelTypes = channelTypes(channelOrder);  % reorder accordingly
            fprintf(1,['Specified channel types:\t' ...
                            sprintf('%s ',channelTypes{:}) '\n']);
        end
    end  % else, use default channelTypes

    if ~isempty(descriptions)  % user specified channel types
        if numel(foundChannels) ~= numel(descriptions)
            msg = 'Need corresponding channels & descriptions\n';
            msg = [msg 'Specified channels:\t' sprintf('%s ',foundChannels{:}) '\n'];
            msg = [msg 'Specified descriptions:' sprintf('\n\t%s',descriptions{:})];
            error(sprintf(msg));
        elseif isempty(channelOrder)
            error('Must specify corresponding channels with channel descriptions')
        else
            descriptions = descriptions(channelOrder); % reorder accordingly
            fprintf(1,['Specified descriptions:\n' ...
                            sprintf('\t%s\n',descriptions{:}) '\n']);
        end
    end  % else, use default descriptions of the |Channel| classes


    if ~isempty(imageProcessors)  % User specified image processors to use
        if numel(foundChannels) ~= numel(imageProcessors)
            msg = 'Need corresponding channels & image processors\n';
            msg = [msg 'Specified channels:\t' sprintf('%s ',foundChannels{:}) '\n'];
            msg = [msg 'Specified image processors:\n' ...
                            sprintf('\t%s\n',imageProcessors{:})];
            error(sprintf(msg));
        elseif isempty(channelOrder)
            error('Must specify corresponding channels with imageProcessors')
        else
            imageProcessors = imageProcessors(channelOrder); % reorder accordingly
            fprintf(1,['Specified image processors:\n' ...
                            sprintf('\t%s\n',imageProcessors{:}) '\n']);
        end
    end  % else, use default |Processor| of each |Channel| class
            

    if verboseFlag
        figH = figure('Units','Normalized','Position',[.25 .25 .5 .5],...
                        'WindowStyle','modal','Name','Processing Results');
        axH = axes('Parent',figH,'NextPlot','replacechildren');
    end

    %--------------------------------------------------------------------
    % Proceed with running the processors on each datafile->channel->obj
    %--------------------------------------------------------------------

    % for each data file
    for k = 1:numel(dataFiles)

        % the image objects in a data file all have the same channels
        dataFileFullPath = [dirPath filesep dataFiles(k).name];
        fprintf(1,'Reading data file: %s\n',dataFileFullPath);
        load(dataFileFullPath);
        if isempty(objects)
            fprintf(1,'\n*** No image_objects in this data file! ***\n\n');
            continue;  % go to the next data file
        end
                

        % for each channel
        for j = 1:numel(foundChannels)
            channelName = foundChannels{j};
            fprintf(1,'\tWorking on %s channel...\n',channelName);

            if isempty(descriptions) 
                desc = '';
            else
                desc = descriptions{j};
            end

            if isempty(imageProcessors) 
                proc = [];
            else
                proc = feval(['postProcessors.' imageProcessors{j}]); 
            end

                   
            % for each |image_object|
            for i = 1:numel(objects)
                
                proc = feval(['postProcessors.' imageProcessors{j}]);
                proc = proc.run(objects(i),channelName); % Run processor
                objects(i).channels.(channelName).metadata.(imageProcessors{j}) = proc; % Store output in image_object

            end  % for each |image_object|

        end % for each channel

        fprintf(1,'Finished with %s, saving...\n',dataFiles(k).name);
        save(dataFileFullPath,'objects');

    end % for each data file

    if verboseFlag
        close(figH);
    end

    fprintf(1,'\n**** ALL DONE PROCESSING DATA ****\n\n');
