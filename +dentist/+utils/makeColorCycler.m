function colorCycler = makeColorCycler()
    colors = {[1,0,0],...%Red
        [0,1,0],...%Blue
        [0,0,1],...%Orange
        [1,162/255,0],...%Pink
        [1,0,102/255],...%Light-blue
        [101/255,205/255,216/255],...%Purple
        [88/255,11/255,78/255],...%Greenish
        [11/255,88/255,63/255],...
        [216/255,142/255,169/255],...
        [165/255,108/255,8/255]};
    colorCycler = dentist.utils.CellArrayCyclicIterator(colors);
end

