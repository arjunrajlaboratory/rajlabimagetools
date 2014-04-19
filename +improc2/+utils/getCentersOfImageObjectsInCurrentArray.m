function centroids = getCentersOfImageObjectsInCurrentArray(arrayNavigator, objectHandle)    
    
    Xs = [];
    Ys = [];
    for i = 1:arrayNavigator.numberOfObjectsInCurrentArray
       arrayNavigator.tryToGoToObj(i)
       [x,y] = improc2.utils.getCenterOfConnectedBWImage(objectHandle.getMask());
       Xs = [Xs, x];
       Ys = [Ys, y];
    end
    
    centroids = dentist.utils.Centroids(Xs, Ys);
end

