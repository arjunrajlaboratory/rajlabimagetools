function [Hs] = layOutStarSearchGUI()
    
    backgColor = [0.247 0.247 0.247];
    
    Hs.figH = figure('Position',[250 100 800 554],...
        'NumberTitle','off',...
        'Name','improc2.ThresholdInspectorGUI',...
        'Resize','on',...
        'Toolbar','none',...
        'MenuBar','none',...
        'Color',backgColor,...
        'Visible','off');
    
    set(Hs.figH, 'Visible', 'on');
    
    Hs.imgAx = axes('Parent',Hs.figH,...
        'Units','normalized',...
        'Position',[0.006,0.009,.675,.976],...
        'XTick',[],'YTick',[]);
    axis(Hs.imgAx, 'equal');
    Hs.thresholdAx = axes('Parent',Hs.figH,...
        'Units','normalized',...
        'Position',[0.690 0.479 0.301 0.316],...
        'YTick',[],...
        'XColor','w');
    Hs.plotLogYCheck = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'BackgroundColor',backgColor,...
        'ForegroundColor',[1 1 1], ...
        'Position',[0.690 0.90 0.201 0.040],...
        'String','log Num Spots','FontSize',12);
    Hs.autoXAxisCheck = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'BackgroundColor',backgColor,...
        'ForegroundColor',[1 1 1], ...
        'Position',[0.690 0.855 0.201 0.040],...
        'String','auto X axis',...
        'ToolTip', ['otherwise set max to image saturation', ...
            'value in ''Fixed'' contrast mode'], ...
        'FontSize',12);
    Hs.hasClearThresholdCheck = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'BackgroundColor',backgColor,...
        'Position',[0.690 0.81 0.201 0.040],...
        'ForegroundColor',[1 1 1], ...
        'String','has Clear Threshold','FontSize',12);
    
    Hs.annotationsButton = uicontrol('Parent',Hs.figH,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.90 0.90 0.09 0.040],...
        'String','AnnotGUI','FontSize',12);
    
    Hs.sliceInspectorButton = uicontrol('Parent',Hs.figH,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.90 0.855 0.09 0.040],...
        'String','See Slices','FontSize',12);
    
    Hs.naviPanel  = uipanel('Parent',Hs.figH,...
        'Units','normalized',...
        'Position',[0.692 0.02 0.3 0.253],...
        'BackgroundColor',[0.929 0.929 0.929]);
    Hs.goodCheck = uicontrol('Parent',Hs.naviPanel,...
        'Style','checkbox',...
        'Units','normalized',...
        'Position',[0.559 0.803 0.403 0.181],...
        'String','Good Object',...
        'Value',0);
    Hs.setFixedToThis = uicontrol('Parent',Hs.naviPanel,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.05 0.803 0.403 0.150],...
        'String','Use for fixed',...
        'FontSize',12, ...
        'Tooltip', 'Use this object''s max intensity for fixed contrast mode in this channel');
    Hs.prevObj = uicontrol('Parent',Hs.naviPanel,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.525 0.622 0.216 0.150],...
        'String','Prev',...
        'FontSize',12,'FontWeight','bold');
    Hs.nextObj = uicontrol('Parent',Hs.naviPanel,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.758 0.622 0.216 0.150],...
        'String','Next',...
        'FontSize',12,'FontWeight','bold');
    
    Hs.countsLabel = uicontrol('Parent',Hs.naviPanel,'Style','text',...
        'String','Spot Count',...
        'Units','normalized',...
        'Position',[0.05 0.55 0.4 0.157],...
        'FontSize',12,'FontWeight','bold');
    Hs.countsDisplay = uicontrol('Parent',Hs.naviPanel,'Style','text',...
        'String','0',...
        'Units','normalized',...
        'Position',[0.05 0.4 0.4 0.157],...
        'FontSize',12,'FontWeight','bold');
    
    Hs.fileLabel = uicontrol('Parent', Hs.naviPanel, ...
        'Style','text',...
        'String',sprintf('File:\n/ '),...
        'Units', 'normalized', ...
        'Position', [0.025 0.1 0.216 0.25], ...
        'FontSize', 12, 'FontWeight', 'bold');
    Hs.goToArray = uicontrol('Parent',Hs.naviPanel,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.275 0.1 0.216 0.25],...
        'FontSize',12);
    Hs.objectLabel = uicontrol('Parent', Hs.naviPanel, ...
        'Style','text',...
        'String',sprintf('Obj:\n/ '),...
        'Units', 'normalized', ...
        'Position', [0.525 0.1 0.216 0.25], ...
        'FontSize', 12, 'FontWeight', 'bold');
    Hs.goToObj = uicontrol('Parent',Hs.naviPanel,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.775 0.1 0.216 0.25],...
        'FontSize',12);
    
    Hs.channelMenu = uicontrol('Parent', Hs.naviPanel,...
        'Style', 'popupmenu', 'String', {''}, ...
        'Value', 1, ...
        'Units', 'normalized',...
        'Position', [0.525 0.331 0.415 0.213]);
    
    
    Hs.dapiCheck  = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'ForegroundColor',[1 1 1], ...
        'BackgroundColor',backgColor,...
        'Position',[0.694 0.365 0.141 0.040],...
        'String','DAPI','FontSize',12);
    Hs.transCheck = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'ForegroundColor',[1 1 1], ...
        'BackgroundColor',backgColor,...
        'Position',[0.839 0.365 0.141 0.040],...
        'String','Trans','FontSize',12);
    Hs.spotsCheck  = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'ForegroundColor',[1 1 1], ...
        'BackgroundColor',backgColor,...
        'Position',[0.694 0.416 0.141 0.040],...
        'String','Spots','FontSize',12);
    Hs.segmentCheck = uicontrol('Parent',Hs.figH,...
        'Style','checkbox',...
        'Units','normalized',...
        'ForegroundColor',[1 1 1], ...
        'BackgroundColor',backgColor,...
        'Position',[0.839 0.416 0.141 0.040],...
        'String','Segmentation','FontSize',12);
    
    Hs.contrastPanel = uipanel('Parent',Hs.figH,...
        'Title','Contrast',...
        'Units','normalized',...
        'Position',[0.694 0.291 0.298 0.074],...
        'BackgroundColor',[0.929 0.929 0.929]);
    Hs.thresholdContrastRadio = uicontrol('Parent',Hs.contrastPanel,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0.009,0.179,0.346,0.857],...
        'HandleVisibility','off',...
        'String','Threshold');
    Hs.fixedContrastRadio = uicontrol('Parent',Hs.contrastPanel,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0.338,0.179,0.376,0.857],...
        'HandleVisibility','off',...
        'String','Fixed');
    Hs.fitContrastRadio = uicontrol('Parent',Hs.contrastPanel,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0.709,0.179,0.286,0.857],...
        'HandleVisibility','off',...
        'String','Fit');
end
