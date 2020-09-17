
Hs.dirPath = pwd;
[Hs.dataFiles,Hs.dataNums] = getDataFiles(Hs.dirPath);
[Hs.foundChannels,Hs.fileNums,Hs.imgExts] = getImageFiles(Hs.dirPath);
for i = 1:length(Hs.fileNums)


    Hs.fileNum = Hs.fileNums(i);    
    fileName = ['dapi' sprintf('%03d',Hs.fileNum) '.tif'];    
    Hs.DI = readmm(fileName);
    Hs.DI = Hs.DI.imagedata;
    Hs.DI = scale(max(Hs.DI(:,:,round(linspace(3,size(Hs.DI,3),4))),[],3));
    binDapi = Hs.DI>adaptthresh(Hs.DI);


                masktmp = imclearborder(binDapi | ~Hs.DI);
                masktmp = bwareaopen(masktmp,5000); 
                if any(masktmp(:))
                    binDapi = masktmp;
                end
    L = bwlabel(binDapi);
    numObjects = max(L,[],1:2);
    Hs.currObjs = [];
    Hs.allMasks = [];
    for j = 1:numObjects
        fnumStr = sprintf('%03d',Hs.fileNum);
        objMask = L == j;
        newObj = improc2.buildImageObject(objMask, fnumStr, Hs.dirPath);

        Hs.currObjs = [Hs.currObjs, newObj];

        Hs.allMasks = cat(3,Hs.allMasks,objMask);
    end

    objects = Hs.currObjs;
    save(sprintf('%s%sdata%03d.mat',Hs.dirPath,filesep,Hs.fileNum),'objects');
    [Hs.dataFiles,Hs.dataNums] = getDataFiles(Hs.dirPath);
    clear objects;
    Hs.currObjs = [];


end