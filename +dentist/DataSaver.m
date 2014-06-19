classdef DataSaver < handle
    
    properties (Access = private)
        dataSources
    end
    
    methods
        function p = DataSaver(dataSources)
            p.dataSources = dataSources;
        end
        
        function dentistData = getDataToSave(p)
            [assignedSpots, centroids, spotToCentroidMappings] = ...
                dentist.utils.saveSpotsAndCentroids(...
                p.dataSources.candidateSpotsAndCentroids);
            
            thresholds = p.dataSources.thresholdsHolder.thresholds;
            
            frequencyTables = dentist.utils.makeFilledChannelArray(...
                p.dataSources.frequencyTableSource.channelNames, ...
                @(channelName) p.dataSources.frequencyTableSource.getSpotFrequencyTable(channelName));
            
            deletionPolygons = p.dataSources.deletionsSubsystem.getPolygons();
            
            dentistData = struct();
            dentistData.centroids = centroids;
            dentistData.assignedSpots = assignedSpots;
            dentistData.spotToCentroidMappings = spotToCentroidMappings;
            dentistData.thresholds = thresholds;
            dentistData.frequencyTables = frequencyTables;
            dentistData.deletionPolygons = deletionPolygons;
        end
        
        function save(p, workingDirectory)
            dentistData = p.getDataToSave();
            dentist.utils.saveData(dentistData, workingDirectory);
        end
    end
    
end

