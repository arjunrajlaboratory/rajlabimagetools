function varargout = suppressNeedsUpdateWarning(funcToRun, varargin)
    
    varargout = cell(1, nargout);
    
    warnState = warning();
    warning('off', 'improc2:NeedsRunOrUpdate')
    
    try
        [varargout{:}] = funcToRun(varargin{:});
    catch err
        warning(warnState)
        rethrow(err)
    end
    warning(warnState)
end
