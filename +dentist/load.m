function spotsAndCentroids = load(dentistData)
    workingDirectory = pwd;
    if nargin < 1
        dentistData = dentist.utils.loadData(workingDirectory);
    end
    
    dataSystem = dentist.buildDataSubystem(dentistData);
    spotsAndCentroids = dataSystem.spotsAndCentroids;