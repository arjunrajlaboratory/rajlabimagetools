%% getImageFiles
% Find the 3D image stack files in the provided directory and store
% their file name, date, bytes, isdir, & datenum information 

%% Input
% * *|dirPath|* - string specifying the directory where to look for image files
%
% _Optional_
%
% * *|numFilter|* - %03d formatted string for a specific file number

%% Output
% * *|foundChannels|* - {string} array with all image file names (RNA & trans/dapi)
% * *|fileNums|* - array of integers specifying the RNA image file numbering
% * *|imgExt|* - {string} array of image file extensions

%% Author
% Marshall J. Levesque 2012

function [foundChannels,fileNums,imgExts] = getImageFiles(dirPath,numFilter)

    % Find a channel we can use for preview of FISH img data, searched 
    % in the order listed below
    channels = {'alexa','cy','gfp','nir','tmr'};
    foundChannels = {};
    RNAchannel = '';
    fileNums = [];
    imgExts = {};
    transNums = []; dapiNums = [];
    if nargin == 1;  
        numFilter = ''; 
    else
        if isempty(regexp(numFilter,'^\d{3}'))
            error('numFilter argument must be %03d formatted string for file number');
        end
    end;

    for channel = channels
        if ~isempty(numFilter)  % already formated string %03d limiting to one filenum
            RNAfiles = dir([dirPath filesep cell2mat(channel) numFilter '.*']);
        else
            RNAfiles = dir([dirPath filesep cell2mat(channel) '*.*']);
        end

        imgExt = [];
        if ~isempty(RNAfiles)
            foundChannels = [foundChannels channel];
            % Use regular expressions to enforce strict filename matching and also 
            % pull out file numbering from filenames for use later
            expr = [cell2mat(channel) '(\d{3}|\d{4})(\.stk|\.tif|.TIF)'];  % channel%03d\.tif/stk only.  Three digit number followed by .stk,.tif OR .TIF
            fileNums = [];
            for k = 1:numel(RNAfiles)
                [tokenStr] = regexp(RNAfiles(k).name,expr,'tokens');
                if isempty(tokenStr)  % name doesn't match
                    fprintf(1,'WARNING: Ignoring %s file\n',RNAfiles(k).name);
                else
                    fileNums = [fileNums str2num(tokenStr{1}{1})];
                    imgExt = tokenStr{1}{2};
                end
            end
            if isempty(RNAchannel)
                RNAchannel = cell2mat(channel);
                fileNumsPrevChan = fileNums;
            end
            if numel(fileNums) ~= numel(fileNumsPrevChan)
                error('RNA files have extra/missing numbering, fix before segmenting');
            elseif ~all(fileNums == fileNumsPrevChan)
                error('RNA files have mixed numbering, fix before segmenting');
            end
        end
        imgExts = [imgExts imgExt]; % save the last image's filename ext in this channel
    end

    if isempty(RNAchannel); return; end;
    
    imgExtTrans = ''; imgExtDapi = '';  % stay empty if no DAPI/trans files
    for fileNum = 1 
        tF = dir([dirPath filesep 'trans' sprintf('%03d',fileNum) '.*']);
        if ~isempty(tF)
            transNums = [transNums; fileNum];
            [d,f,imgExtTrans] = fileparts(tF.name);
        end
        dF = dir([dirPath filesep 'dapi' sprintf('%03d',fileNum) '.*']);
        if ~isempty(dF)
            dapiNums  = [dapiNums; fileNum];
            [d,f,imgExtDapi] = fileparts(dF.name);
        end
    end
    imgExts = [imgExts imgExtDapi]; % save the last DAPI filename ext
    imgExts = [imgExts imgExtTrans]; % save the last trans filename ext

%     % Check the numbering of files between all channels
%     if ~isempty(transNums) 
%         foundChannels = [foundChannels 'trans']; 
%         if numel(fileNums) ~= numel(transNums)
%             error('Numbering of RNA/trans files does not match');
%         end
%     end
% 
%     if ~isempty(dapiNums)  
%         foundChannels = [foundChannels 'dapi'];  
%         if numel(fileNums) ~= numel(dapiNums)
%             error('Numbering of RNA/dapi files does not match');
%         end
%     end

    % sort alphabetical since a lot of other functions MATLAB (e.g. intersect()) 
    % do this stuff automatically and we want our indexing consistent
    [foundChannels,I] = sort(foundChannels);
    imgExts = imgExts(I);
