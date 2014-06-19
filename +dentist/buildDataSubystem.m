function out = buildDataSubystem(resources)
    
    centroids = resources.centroids;
    assignedSpots = resources.assignedSpots;
    spotToCentroidMappings = resources.spotToCentroidMappings;
    thresholds = resources.thresholds;
    frequencyTables = resources.frequencyTables;
    deletionPolygons = resources.deletionPolygons;
    
    candidateSpotsAndCentroids = dentist.utils.SpotsAndCentroids(...
        assignedSpots, centroids, spotToCentroidMappings);
    
    deleteableCandidates = dentist.utils.DeleteableSpotsAndCentroids(...
        candidateSpotsAndCentroids);
    
    notifyingDeleter = dentist.utils.NotifyingDeleter(deleteableCandidates);
    
    deletionsPolygonStack = dentist.utils.PolygonStack();
    for i = 1:length(deletionPolygons)
        deletionsPolygonStack.addPolygon(deletionPolygons{i});
    end
    
    polygonBasedDeletionsTool = dentist.utils.PolygonsBasedDeletionsTool(...
        deletionsPolygonStack, notifyingDeleter);
    polygonBasedDeletionsTool.setDeletionsToMatchPolygons();
    deletionsSubsystem = dentist.utils.DeletionsSubsystem(...
        notifyingDeleter, polygonBasedDeletionsTool);
    
    thresholdsHolder = dentist.utils.ThresholdsHolder(thresholds);
    spotsAndCentroids = dentist.utils.SpotsPassingThresholdAndCentroids(...
        deleteableCandidates, thresholdsHolder);
    frequencyTableSource = dentist.utils.FrequencyTableSource(frequencyTables);
    
    
    dataSources = struct();
    dataSources.candidateSpotsAndCentroids = candidateSpotsAndCentroids;
    dataSources.thresholdsHolder = thresholdsHolder;
    dataSources.frequencyTableSource = frequencyTableSource;
    dataSources.deletionsSubsystem = deletionsSubsystem;
    
    dataSaver = dentist.DataSaver(dataSources);
    
    out = struct();
    out.deletionsSubsystem = deletionsSubsystem;
    out.thresholdsHolder = thresholdsHolder;
    out.spotsAndCentroids = spotsAndCentroids;
    out.frequencyTableSource = frequencyTableSource;
    out.dataSaver = dataSaver;
    
end

