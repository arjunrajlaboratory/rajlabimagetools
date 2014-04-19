function results = processimageobjects(varargin)
    p = inputParser;
    p.addOptional('directory',pwd,@isstr);
    p.addOptional('channels',{},@iscell);
    p.addOptional('initialProcessorData',{},@iscell);
    p.parse(varargin{:});
    
    results = p;
end

