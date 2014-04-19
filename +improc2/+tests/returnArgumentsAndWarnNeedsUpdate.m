function varargout = returnArgumentsAndWarnNeedsUpdate(varargin)
    varargout = cell(1,nargout);
    
    for i = 1:nargout
        varargout{i} = varargin{i};
    end
    
    warning('improc2:NeedsRunOrUpdate', 'Mock function that thows warning')
    
end

