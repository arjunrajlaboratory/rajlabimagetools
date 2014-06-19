improc2.tests.cleanupForTests;

cd ~/code/dentistTestData/3by3

if exist('dentistConfig.mat', 'file')==2
    delete('dentistConfig.mat');
end

%%

Nrows = 3;
Ncols = 3;

dentist.initialize(3,3);

%%

layout = struct();
layout.layoutIndex = 5;
[layout.nextFileDirection, ...
    layout.secondaryDirection, ...
    layout.snakeOrNoSnake] = ...
    dentist.utils.interpretLayoutTypeNumber(layout.layoutIndex);
dentist.setLayout(layout);
%dentist.setLayout();

%%

dentist.setImageOverlap(103);
% dentist.setImageOverlap();

%%

dentist.processImages();