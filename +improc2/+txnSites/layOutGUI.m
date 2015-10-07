function guiHs = layOutGUI()

backgColor = [0.247 0.247 0.247];

guiHs = struct();

guiHs.figH = figure('NumberTitle','off',...
    'Name','TxnSites',...
    'Resize','on',...
    'Toolbar','none',...
    'MenuBar','none',...
    'Color',backgColor,...
    'Visible','on');

imgPanel = uipanel('Parent', guiHs.figH, ...
    'Units','normalized',...
    'Position',[0 0.2 1 0.75],...
    'BorderType', 'none', ...
    'BackgroundColor',backgColor);

controlsPanel = uipanel('Parent', guiHs.figH, ...
    'Units','normalized',...
    'Position',[0 0.005 1 0.19],...
    'BorderType', 'none', ...
    'BackgroundColor',backgColor);


guiHs.imgAx = axes('Parent', imgPanel);

guiHs.intronMultiplierLabel = uicontrol('Style','text',...
    'Parent', imgPanel, ...
    'Units', 'normalized', ...
    'Position',[0.835 0.94 0.12 0.05],...
    'String','intron adjust', ...
    'BackgroundColor',backgColor);

guiHs.exonMultiplierLabel = uicontrol('Style','text',...
    'Parent', imgPanel, ...
    'Units', 'normalized', ...
    'Position',[0.835 0.77 0.12 0.05],...
    'String','exon adjust', ...
    'BackgroundColor',backgColor);

guiHs.intronMultiplierTextBox = uicontrol('Style', 'edit', ...
    'Parent', imgPanel, ...
    'Units', 'normalized', ...
    'Position', [0.85, 0.85, 0.09 0.09], ...
    'String', '');

guiHs.exonMultiplierTextBox = uicontrol('Style', 'edit', ...
    'Parent', imgPanel, ...
    'Units', 'normalized', ...
    'Position', [0.85, 0.68, 0.09 0.09], ...
    'String', '');

axis(guiHs.imgAx, 'equal');

guiHs.zoomButton = uicontrol('Style', 'radiobutton', ...
    'Parent', controlsPanel, ...
    'Units', 'normalized', ...
    'Position', [0.05 0 0.3 1], ...
    'String','zoom');

guiHs.panButton = uicontrol('Style', 'radiobutton', ...
    'Parent', controlsPanel, ...
    'Units', 'normalized', ...
    'Position', [0.3 0 0.3 1], ...
    'String','pan');

guiHs.addButton = uicontrol('Style', 'radiobutton', ...
    'Parent', controlsPanel, ...
    'Units', 'normalized', ...
    'Position', [0.55 0 0.3 1], ...
    'String', 'add');

guiHs.clearAllButton = uicontrol('Style', 'pushbutton', ...
    'Parent', controlsPanel, ...
    'Units', 'normalized', ...
    'Position', [0.8 0 0.15 0.4], ...
    'String', 'clear all');

guiHs.deleteLastButton = uicontrol('Style', 'pushbutton', ...
    'Parent', controlsPanel, ...
    'Units', 'normalized', ...
    'Position', [0.8 0.5 0.15 0.4], ...
    'String', 'delete last');


end
