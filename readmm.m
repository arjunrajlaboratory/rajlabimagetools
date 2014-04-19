%% readmm
% Reads MetaMorph stk files or .tif/.tiff files

%% Input
% *|infile|* - filename or full filepath string of the image stack
% 
% Optional Argument: indices of the image stack planes to read from the file

%% Output
% *|tiff|* - |struct()| with image metadata and the all important .imagedata field

%% Usage
%  >> T1 = readmm('tmr001.stk');  % read image stack in working directory
%
%  >> T1 = readmm('/Volumes/ImgData/2011-03-04/tmr001.stk'); % read from specific filepath
%
%  >> T1 = readmm('tmr001'); % shortcut to file in the current directory
%
%  >> T1 = readmm('tmr001.stk',10);  % read only the 10th plane in the image stack

%% Author
% Arjun Raj (the original) 
%
% Marshall J. Levesque 2011

function tiff = readmm(infile,varargin)

%---------------------------------------------------------------------------------------
% Start by validating the filepath input argument. We perform some checks to make sure
% we have a valid file and also some cross-platform filepath editing if someone writes
% code that explicitly calls readmm with a full filepath string and we need to swap 
% Mac/Windows forward or backward slashes
%---------------------------------------------------------------------------------------
if ischar(infile)
    infile = regexprep(infile,'[\\\/]',filesep);  % replace platform-specifc slash character
    % the wildcard character allows the user to provided a shortcut for image stack file in 
    % the current working directory
    d = dir([infile '*']); 

    if isempty(d)
        error('infile argument was not a valid filepath string');
    elseif length(d) > 1
        msg = sprintf('infile argument shortcut matched more than one file in the path');
        error('infile argument shortcut matched more than one file in the path');
    elseif d.isdir
        error('infile argument provided was for a directory instead of a image stack file');
    end

    % we should now have a valid filepath or filename shortcut for a file in current dir 
    [filepath,fname,fext] = fileparts(infile);
    if isempty(fext)  % the wildcard has appended a filename extension to shortcut
        infile = d.name; 
        [filepath,fname,fext] = fileparts(infile);
    end

    if isempty(filepath)
        filepath = pwd;
    end

else
    error('First argument must be a string specifing a filepath to an image stack')
end

fullFilepath = fullfile(filepath,[fname fext]);
tiff.filename = fullFilepath;

%-----------------------------------------------------------------------------------
% Decided whether the file is a TIFF or MetaMorph STK file and proceed accordingly
%-----------------------------------------------------------------------------------
if any(strcmpi(fext,{'.tiff','.tif'}))  % This means we have a TIFF file, allow *.TIF/TIFF

    info = imfinfo(fullFilepath);
    tiff.numplanes = length(info);
    tiff.width = info(1).Width;
    tiff.height = info(1).Height;
    tiff.bitspersample = info(1).BitsPerSample;
    if tiff.bitspersample == 16
        im_type = 'uint16';
    elseif tiff.bitspersample == 8
        im_type = 'uint8';
    end;
    
    if length(varargin) == 0
        inds = 1:tiff.numplanes;
    else
        inds = varargin{1};
    end;
    
    tiff.imagedata = zeros(tiff.height, tiff.width, length(inds),im_type);
    for i = 1:length(inds)
        tiff.imagedata(:,:,i) = imread(fullFilepath,'index',inds(i));
    end;
    
elseif strcmpi(fext,'.stk')  % This means we are working with a MetaMorph STK file
    
    fid = fopen(fullFilepath,'r');
    
    a = fread(fid,2,'char'); % This should be 'II'
    a = fread(fid,1,'uint16');  % This should be 42
    
    currifd = fread(fid,1,'uint32');  % This is the location of the first IFD
    
    fseek(fid,currifd,-1);  % Seek to the first IFD (location from bof)
    
    numentries = fread(fid,1,'uint16');
    
    %clear entry
    for i = 1:numentries
        entries_one(i).tag    = fread(fid,1,'uint16');
        entries_one(i).type   = fread(fid,1,'uint16');
        entries_one(i).count  = fread(fid,1,'uint32');
        entries_one(i).value  = fread(fid,1,'uint32');
    end;
    
    tags = [entries_one(:).tag];
    
    i = find(tags == 258);
    tiff.bitspersample = entries_one(i).value;
    
    i = find(tags == 256);
    tiff.width = entries_one(i).value;
    
    i = find(tags == 257);
    tiff.length = entries_one(i).value;
    
    i = find(tags == 306);
    fseek(fid,entries_one(i).value,-1);
    str = fread(fid,20,'*char');
    tiff.datetime = str';
    %tiff.length = entries_one(i).value;
    
    
    
    
    i = find(tags == 33629);  % This is UIC2
    % It contains the z positions and creation date and so forth
    tiff.numplanes = entries_one(i).count;
    numplanes = tiff.numplanes;
    zpos = zeros(numplanes,1);
    creationdate = zeros(numplanes,1,'uint32');
    creationtime = zeros(numplanes,1,'uint32');
    modificationdate = zeros(numplanes,1,'uint32');
    modificationtime = zeros(numplanes,1,'uint32');
    fseek(fid,entries_one(i).value,-1);
    
    % The following code was for reading date and time info.
    % I don't use it, so I thought, whatever, just remove it.
    for i = 1:numplanes
        num = fread(fid,1,'uint32');
        den = fread(fid,1,'uint32');
        zpos(i) = num/den;
        creationdate(i) = fread(fid,1,'uint32');
        creationtime(i) = fread(fid,1,'uint32');
        modificationdate(i) = fread(fid,1,'uint32');
        modificationtime(i) = fread(fid,1,'uint32');
    end;
    tiff.creationdate = creationdate;
    tiff.creationtime = creationtime;
    
    
    % Now let's read the annotations.
    i = find(tags == 270);
    fseek(fid,entries_one(i).value,-1);  % This is the location of the annotation
    for i = 1:numplanes
        byte = fread(fid,1,'*char');
        string = byte;
        while byte ~= 0
            byte = fread(fid,1,'*char');
            string = [string byte];
        end;
        tiff.annotation{i} = string;
    end;
    % Now let's read the exposure times out.
    for i = 1:numplanes
        an = tiff.annotation{i};
        [a,b] = strread(an,'%s%s','delimiter',':');
        tiff.exposure(i) = b(1);
    end
    
    % Okay, now we'll read the rest of the file to get the illumination settings.
    % This is a pretty bad hack, but whatever... it seems to work.
    rest = fread(fid,inf,'*char')';
    idx = strfind(rest,'Illum');
    % Now we have the offsets.  The way it works is that first you have the text
    % "_IllumSetting_" followed by the number 2 (byte), followed by 32 bytes
    % that I don't understand, followed by a byte containing the length of
    % the string.  In total, this number is 18 bytes later.
    for i = 1:length(idx) % length(idx) should equal numplanes
        pos = idx(i)+18;
        len = double(rest(pos));
        tiff.illumination{i} = rest( (pos+1):(pos+len) );
    end;
    
    
    % This actually reads the data
    i = find(tags == 273);
    fseek(fid,entries_one(i).value,-1);
    stripoffset = fread(fid,1,'uint32');
    
    if length(varargin) == 0  % Then we read all the data
        fseek(fid,stripoffset,-1);
        tiff.imagedata = fread(fid,tiff.width*tiff.length*numplanes,'*uint16');
        tiff.imagedata = reshape(tiff.imagedata,tiff.width,tiff.length,numplanes);
    else % Okay, so now we have to read out individual files
        inds = varargin{1};
        tiff.imagedata = zeros(tiff.width,tiff.length,length(inds),'uint16');
        for i = 1:length(inds)
            currpos = stripoffset + tiff.width*tiff.length*(inds(i)-1)*tiff.bitspersample/8;
            fseek(fid,currpos,-1);
            tmp2 = fread(fid,tiff.width*tiff.length,'*uint16');
            tiff.imagedata(:,:,i) = reshape(tmp2,tiff.width,tiff.length);
        end;
    end;%  for i = 1:length(
    
    
    if length(varargin) ~=0  %If we just want a few images, let's clean up
        inds = varargin{1};
        %tiff.numplanes = length(inds);
        for i = 1:length(inds)
            tmp.annotation{i}   = tiff.annotation{inds(i)};
            tmp.exposure{i}     = tiff.exposure{inds(i)};
            tmp.illumination{i} = tiff.illumination{inds(i)};
        end;
        tiff.annotation   = tmp.annotation;
        tiff.exposure     = tmp.exposure;
        tiff.illumination = tmp.illumination;
    else
        inds = 1:numplanes;
    end;
    
    tiff.imageindices = inds;
    
    fclose(fid);

else 

    error('infile argument must be a file with valid extension ''.stk'' or ''.tif/tiff''');

end


