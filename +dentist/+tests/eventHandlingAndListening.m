close all; clear; clear classes;

viewport = dentist.utils.ImageViewport(10,10);
x = dentist.utils.LiveViewportDisplayer(viewport, 'barney');
%%
close all; clear; clear classes;
x = inputParser();
x.addParamValue('Center', []);
x.addParamValue('cookie', 'crisp');
