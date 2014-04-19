function varargout = launchAnnotationsAdder(dirPathOrAnArrayCollection)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
    
    annotationsAdder = improc2.AnnotationsAdder(tools.annotationItemAdder, ...
        tools.annotations, tools.iterator);
    if nargout == 1
        varargout = cell(1);
        varargout{1} = annotationsAdder;
    elseif nargout == 0
        assignin('base', 'annotationsAdder', annotationsAdder);
        fprintf('annotationsAdder was created in your workspace\n')
    end
end

