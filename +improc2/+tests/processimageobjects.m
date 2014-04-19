%% processimageobjects
% The long-awaited sequel to the workhorse of Raj Lab image processing

%% Description
% Find all |data*.mat| files that contain the segmented |image_objects|, set any 
% specified processing details, and run the image processing routines. 

%% Input
% _Optional_ (uses *'param','value'* paired input style)
%
% * *|verbose|* - see the visual results (spots on images) of processing 
%
% * *|directory|* - specify the location of the |data*.mat| files
%   The image files themselves should be in either the directory specified
%   here, the directory specified within the image objects, or MATLAB's
%   current working directory: see improc2.ImageObjectFullStkProvider.
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

% Example Usage
% *Most simple/common usage case*
%  >> SegmentGUI
%  >> improc2.processimageobjects
%  >> load data001
%  >> objects(1).channels.tmr.processor.plotImage  % see the results of processing 
%
% *

%% Author
% Marshall J. Levesque 2012
% Refactored by Gautham Nair 2013

function processimageobjects(varargin)
    
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
    if GUI
        msg = sprintf(['\n\t**NOTICE**\t\n' ...
            '\tGUI not yet implemented.\n' ...
            'Continue with given command line parameters?\n' ...
            '(Hint: common use requires no parameters) (y/n) ']);
        yn = input(msg,'s');
        if isempty(yn); yn = 'n'; end;  % default when press return only
        if ~any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            fprintf(1,'\n\t Aborted. Check documentation in *.m file for command line usage\n');
            return;
        end
        GUI = false;
    end
    
    dirPath = p.Results.directory;
    filesToProcess = p.Results.fileNums;
    
    channelsToProcess = p.Results.channels;
    channelTypes = p.Results.channelTypes;
    imageProcessors = p.Results.imageProcessors;
    descriptions = p.Results.descriptions;
    
    verboseFlag = p.Results.verbose;

    %------------------------------------------------------------------
    % Retreive and check the input 'data***.mat' files
    % Prompts user to choose different directory if none found in given.
    %------------------------------------------------------------------
    dirPath = ensureDataExists(dirPath);
    
    % Also look for image files in the data directory
    foundChannels = getImageFiles(dirPath);

%  **TODO**    GUI does not work in this implementation yet.    
    if GUI
        improc2.ProcessDataGUI(dirPath,dataFiles,dataNums);
        return;
    end
    
    % Validate user request to process certain channels, and figure out
    % their order.
    [foundChannels, channelOrder] = ...
        chooseAndOrderChannels(channelsToProcess, foundChannels);

    % Validation and ordering of other user-specified specs for channels.
    channelTypes = formatChannelSpecs(foundChannels, channelOrder, ...
        channelTypes, 'channelTypes');
    descriptions = formatChannelSpecs(foundChannels, channelOrder, ...
        descriptions, 'descriptions');
    imageProcessors = formatChannelSpecs(foundChannels, channelOrder, ...
        imageProcessors, 'image processors');
            

    if verboseFlag
        figH = figure('Units','Normalized','Position',[.25 .25 .5 .5],...
                        'WindowStyle','modal','Name','Processing Results');
        axH = axes('Parent',figH,'NextPlot','replacechildren');
    end

    %--------------------------------------------------------------------
    % Proceed with running the processors on each datafile->channel->obj
    %--------------------------------------------------------------------


clearToProceed = false;
croppedStkProvider = improc2.ImageObjectCroppedStkProvider(dirPath);

% for each channel
for j = 1:numel(foundChannels)
    channelName = foundChannels{j};
    fprintf(1,'* Working on %s channel...\n',channelName);
    
    % get the user defined / or default description for the channel
    if isempty(descriptions)
        desc = '';
    else
        desc = descriptions{j};
    end

    % for each object
    objIter = improc2.imageObjectUpdater(dirPath, filesToProcess);
    while objIter.hasNext()

        obj = objIter.next();
        
        clearToProceed = checkIfProcessedOrClear(obj, channelName, clearToProceed);
        
        % instantiate the imageProcessor.Processor
        if isempty(imageProcessors)    
            proc = [];
        else
            proc = feval([imageProcessors{j}]);
        end

        % instantiate the Channel
        filename = obj.channels.(channelName).filename;        
        if isempty(channelTypes)
            C = getDefaultChannel(channelName, filename, desc, proc);
        else
            C = feval([channelTypes{j}], filename,desc,proc);
        end
                       
        
        croppedStkProvider.loadImage(obj, channelName);
        % crop the image stack for the image_object bounding box
        croppedImg = croppedStkProvider.croppedimg;
        mask = obj.object_mask.mask;

        % process the cropped image stack with currrent channel processor
        % |Processor| object is returned, this contains:
        % * modifed Processor object contains processing results and
        % * representative version of the cropped image stack, also
        % * convenience functions for plotting
        
        if isa(C.processor,'imageProcessors.aTrousGaussFits')
            srcImgPath = [obj.filenames.path filesep filename];
            segmentationRect = obj.object_mask.boundingbox;
            C.processor = C.processor.run(croppedImg,...
                mask,...
                srcImgPath,...
                segmentationRect);
        else
            C.processor = C.processor.run(croppedImg,mask);
        end

        obj.channels.(channelName) = C;
        
        % plot the results
        if verboseFlag
            if ~ishandle(axH)
                axH = axes('NextPlot','replacechildren');
            end
            obj.channels.(channelName).processor.plotImage(axH);
            infoStr = ''; % TODO: make this informative 
            text('Parent',axH,'Units','Normalized','Position',[.1 .1],...
                'String',infoStr,'Color','green','FontSize',16);
            drawnow
        end
        
        objIter.replaceCurrObj(obj);
        
    end % for each object
    objIter.delete();

end % for each channel
croppedStkProvider.delete();

    if verboseFlag
        close(figH);
    end

    fprintf(1,'\n**** ALL DONE PROCESSING DATA ****\n\n');
end


function clearToProceed = checkIfProcessedOrClear(obj, channelName, clearToProceed)
% Check if this channel has already been processed, ask the user
% if they want to continue and overwrite data
% ensure this channel is the new |Channel| class. Old style data
% was just a plain struct() with no explict status provided
if isa(obj.channels.(channelName),'improc2.Channel')
    if obj.channels.(channelName).isProcessed && ~clearToProceed
        msg = sprintf(['\n\t**NOTICE**\t\n'...
            'This data file has been processed and continuing will overwrite '...
            'saved data.\n Continue for all files? (y/n) ']);
        yn = input(msg,'s');
        if isempty(yn); yn = 'n'; end;  % default when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            clearToProceed = true;
        else
            fprintf(1,'Aborted processing, check your data files\n');
            error('Aborted Processing\n');
        end
    end
end
end


function [dirPath, dataFiles, dataNums] = ensureDataExists(dirPath)
    
    [dataFiles,dataNums] = getDataFiles(dirPath);    
    % Make sure that there are data files in the requested directory. 
    % Otherwise, ask the user to locate a directory with data files to
    % process.
    if isempty(dataNums)
        fprintf(1,'Could not find data files!\n');
        yn = input('Navigate to the directory with your files? y/n [y]','s');
        if isempty(yn); yn = 'y'; end;  % default answer when press return only
        if any(strcmp(yn,{'y','Y','yes','Yes','YES','1'}))
            dirPath = uigetdir(pwd,'Navigate to data & image files');
            if dirPath == 0;  % User pressed cancel 
                return;  % quit the GUI
            end
            [dataFiles,dataNums] = getDataFiles(dirPath);
        end
        if isempty(dataNums)
            error('Could not find data files in this directory');
        end
        % user did not want to navigate to data/image files, quit
        
    end
end

function xformatted = formatChannelSpecs(foundChannels, channelOrder, x, xtypestring)
    xformatted = x;
    if ~isempty(x)  
        if numel(foundChannels) ~= numel(x)
            msg = ['Need corresponding channels & ', xtypestring, '\n'];
            msg = [msg 'Specified channels:\t' sprintf('%s ',foundChannels{:}) '\n'];
            msg = [msg 'Specified ' xtypestring ':' sprintf('\n\t%s',x{:})];
            error(sprintf(msg));
        elseif isempty(channelOrder)
            error(['Must specify corresponding channels with channel ' xtypestring])
        else
            xformatted = x(channelOrder); % reorder accordingly
            fprintf(1,['Specified ' xtypestring ':\n' ...
                            sprintf('\t%s\n',x{:}) '\n']);
        end
    end  % else, will end up using default x for each channel.
end

function [foundChannels, channelOrder] = chooseAndOrderChannels(channelsToProcess, foundChannels)
    channelOrder = []; % checked whether input has corresponding channels with options
    if ~isempty(channelsToProcess)  % User specified a subset of channels to process
        [matchingChannels,matchingInds] = intersect(foundChannels,channelsToProcess);
        if isempty(matchingChannels) || ...
                        numel(matchingChannels) ~= numel(channelsToProcess)
            msg = 'Specified channels do not match the image filenames\n';
            msg = [msg 'Found image files:\t' ...
                            sprintf('%s ',foundChannels{:}) '\n'];
            msg = [msg 'Specified channels:\t' sprintf('%s ',channelsToProcess{:})];
            error(sprintf(msg));
        else
            foundChannels = foundChannels(matchingInds);
            fprintf(1,['Specified image channels:\t' ...
                            sprintf('%s ',foundChannels{:}) '\n' ]);
            [matchingChannels,channelOrder] = ...
                    intersect(channelsToProcess,matchingChannels);
        end
    end  % else, use the |foundChannels| from getImageFiles()
end

function C = getDefaultChannel(channelName, filename, desc, proc)

    if strcmp(channelName,'dapi')
        C = channels.dapiChannel(filename,desc,proc);
    elseif strcmp(channelName,'trans')
        C = channels.transChannel(filename,desc,proc);
    else
        C = channels.fishSpotsChannel(filename,desc,proc);
    end

end
