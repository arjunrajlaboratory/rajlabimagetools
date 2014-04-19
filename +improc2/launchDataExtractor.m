function varargout = launchDataExtractor(dirPathOrAnArrayCollection)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    tools = improc2.launchImageObjectTools(dirPathOrAnArrayCollection);
    
    
    annotationExtractor = improc2.extraction.AnnotationDataExtractor(tools.annotations);
    processorDataExtractor = improc2.extraction.ProcessorDataExtractor(tools.objectHandle);
    objectHandleExtractor = improc2.extraction.ObjectHandleDataExtractor(tools.objectHandle);
    
    dataExtractor = improc2.extraction.DataExtractorFromAllObjects(...
        tools.iterator, tools.navigator, objectHandleExtractor, processorDataExtractor, ...
        annotationExtractor);
    if nargout == 1
        varargout = cell(1);
        varargout{1} = dataExtractor;
    elseif nargout == 0
        assignin('base', 'dataExtractor', dataExtractor);
        fprintf('\n*!* dataExtractor was created in your workspace\n\n')
    end
end