function [volData] = calcVolume(color)
% Calculates the volume of the cell based on spots from a "fill color".
% function [volData] = calcVolume(color)
% color = color of spots used to fill the cell, usually 'nir'

radius = 35;
contents = dir('data*');
m = 1;
%clear volData;

msgid = 'MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId';
s = warning('off',msgid);

for i = 1:numel(contents)
    load(contents(i).name);
    fprintf('loading %s\n',contents(i).name);
    for j = 1:numel(objects)
        
        fprintf('loading object %d\n',j);
        
        obj = objects(j);
        
        if ~isfield(obj.metadata,'planeSpacing')
            disp('Need to tell me plane spacing. Please run function recordStackInfo.');
            return;
        end
        
        if isfield(obj.metadata,'volumeRealUnits')
           continue;
        end
        
        if obj.isGood == 0
            continue;
        end
        
        if numel(obj.channels.dapi.processor.mask) < 10
            continue;
        end
        
        x = obj.channels.(color).spotCoordinates(:,2);
        y = obj.channels.(color).spotCoordinates(:,1);
        z = obj.channels.(color).spotCoordinates(:,3);
        
        tic;
        
        % Given real coordinates, calculate the volume of the cell.  This is vOrig.
        % This function will return cellTopOrig and cellBottomOrig.
        [vOrig cellTopOrig cellBottomOrig] = findVol_Expand2(obj, color, x, y, z, 1,radius);
        
        % Populate the shell (cellTopOrig, cellBottomOrig) above with points until
        % the number of points is close to the initial number.  These are
        % xf, yf, zf.
        [xf yf zf] = fillVol2(obj, color, cellTopOrig, cellBottomOrig, numel(x), 1);
        
        % Using xf, yf, zf, calculate the volume.  This is vFake.  This should be
        % smaller than vReal.  This gives us initial vFake, and the beginning of
        % the interval for the binary search algorithm.
        [vFake cellTopFake cellBottomFake] = findVol_Expand2(obj, color, xf, yf, zf, 1,radius);
        
        if vFake < vOrig
            begInt = 1;
        else % This is a hack, I don't expect this to happen...
            disp('fake volume is larger than expected');
            begInt = 0.5;
        end
        
        % Now expand cellTopOrig and cellBottomOrig by expFactor.  Repopulate with
        % new random points.  Calculate a new vFake.  Reapeat until vFake and vReal
        % are within ~1% of each other.
        
        % BINARY SEARCH
        
        % First just find the intervals
        
        expFactor = vOrig/vFake;
        %idx = 1;
        %flag = 0;
        while 'true'
            %if idx > 1
            %    flag = 1;
            %    break;
            %end
            disp('FINDING INTERVAL');
            
            [xf yf zf] = fillVol2(obj, color, cellTopOrig, cellBottomOrig, numel(x), expFactor);
            
            [vFake cellTopFake cellBottomFake] = findVol_Expand2(obj, color, xf, yf, zf, expFactor,radius);
            

            if vFake > vOrig
                endInt = expFactor;
                break;
            else
                expFactor = 1.1*expFactor;
            end
            %idx = idx + 1;
        end
        
        %if flag == 1
        %    continue;
        %    disp('flag == 1');
        %end
        
        expFactor = (begInt+endInt)/2;
        while 'true'

            disp('FINDING REAL VOLUME');
            
            [xf yf zf] = fillVol2(obj, color, cellTopOrig, cellBottomOrig, numel(x), expFactor);
            
            [vFake cellTopFake cellBottomFake] = findVol_Expand2(obj, color, xf, yf, zf, expFactor,radius);
            
            if abs(1-vOrig/vFake)<0.01
                break;
            elseif vOrig/vFake > 1 %this means our expFactor is too small
                begInt = expFactor; %make this the beginning of our interval
                expFactor = (endInt+begInt)/2; %increase expFactor
            else %this means our expFactor is too large
                endInt = expFactor; %make this the end of the interval
                expFactor = (endInt+begInt)/2;
            end
        end
        
        cellTopReal = imresize(cellTopOrig,expFactor);
        cellTopReal = cellTopReal*expFactor;
        cellBottomReal = imresize(cellBottomOrig,expFactor);
        cellBottomReal = cellBottomReal*expFactor;
        
        mask = imresize(obj.object_mask.mask,expFactor);
        dapiMask = imresize(obj.channels.dapi.processor.mask,expFactor);
        
        height = cellTopReal-cellBottomReal;
        height(isnan(height)) = 0;
        height(~mask) = 0;
        volumeWithNuc = sum(height(:));
        height(dapiMask) = 0;
        volume = sum(height(:));
        volumeRealUnits = volume*0.125*0.125*obj.metadata.planeSpacing;
        
        toc;
        
        volData(m,:) = [i j volume volumeWithNuc];
        m = m+1;
        
        %objects(j).metadata.volumeNEW = volume;
        objects(j).metadata.volumeRealUnits = volumeRealUnits;
    end
    fprintf('Saving %s\n',contents(i).name);
    save(contents(i).name,'objects');
end

warning(s);
%dlmwrite('volume_expand_battleship.txt',volData,'\t');
