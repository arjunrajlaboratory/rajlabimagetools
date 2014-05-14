function h = viewImageObjectDataGraph(dirPathOrAnArrayCollection)
    if nargin < 1
        dirPathOrAnArrayCollection = pwd;
    end
    
    tools = improc2.launchImageObjectBrowsingTools(dirPathOrAnArrayCollection);
    fprintf('Displaying object 1 of array 1\n')
    h = view(tools.objectHandle);
end

