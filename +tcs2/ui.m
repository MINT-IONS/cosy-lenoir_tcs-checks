function ui
% ui  Graphical user interface for the TCS2.
%   tcs2.ui

figure;


% P.Neutral_Temperature = {32, [20 40], '°C', .1, 'Nxxx'};
% P.Stimulation_Temperature = {48, [10 60], '°C', .1, 'C0xxx'};
% P.Stimulation_Duration = {1500, [1 99999], 'ms', 1, 'D0xxxxx'}; % scale???
% P.Ramp_Up = {70, [.1 999.9], '°/s', .1, 'V0xxxx'}; % scale???
% P.Ramp_Down = {40, [.1 999.9], '°/s', .1, 'R0xxxx'}; % scale???

%% Load XL File
xlfile = [fileparts(which('tcs2.ui')) filesep 'TCS2-Parameters.xlsx'];
T = readtable(xlfile);

%% Create Children Panels In Father Panel
pAll = uipanel;

pParams = [];
dx = .01;
dy = .01;
m = height(T);
for p = 1:m
    h = (1-(m+1)*dy)/m;
    pParams(p,1) = uipanel('Parent',pAll, 'Pos',[dx dy+(m-p)*(dy+h) 1-2*dx h]);
end

%% Create Objects In Children Panels
for p = 1:m
    w1 = .3;
    param = T.Parameter{p};
    uicontrol('Parent',pParams(p), 'Style','text', 'Str',param, ...
        'HorizontalAlignment','left', 'FontSize',16, 'FontWeight','bold', ...
        'Unit','norm', 'Pos',[0 0 w1 1]);
    
    w2 = .1;
    uicontrol('Parent',pParams(p), 'Style','edit', 'Str',T.value(p), 'Tag',param, ...
        'HorizontalAlignment','center', 'FontSize',18, 'FontWeight','bold', ...
        'Unit','norm', 'Pos',[w1 0 w2 1]);
    
    w3 = .08;
    uicontrol('Parent',pParams(p), 'Style','text', 'Str',['(' T.unit{p} ')'], ...
        'HorizontalAlignment','left', 'FontSize',16, 'ForegroundColor',.2*[1 1 1], ...
        'Unit','norm', 'Pos',[w1+w2 0 w3 1]);
    
    w4 = .10;
    plusminus = char(177);
    uicontrol('Parent',pParams(p), 'Style','text', 'Str',[plusminus num2str(T.step(p))], ...
        'HorizontalAlignment','center', 'FontSize',16, 'ForegroundColor',.4*[1 1 1], ...
        'Unit','norm', 'Pos',[w1+w2+w3 0 w4 1]);
    
    w5 = .18;
    uicontrol('Parent',pParams(p), 'Style','text', 'Str',['(' num2str(T.min(p)) ' - ' num2str(T.max(p)) ')'], ...
        'HorizontalAlignment','center', 'FontSize',16, 'ForegroundColor',.4*[1 1 1], ...
        'Unit','norm', 'Pos',[w1+w2+w3+w4 0 w5 1]);
    
    w6 = .15;
    uicontrol('Parent',pParams(p), 'Style','text', 'Str',T.cmd{p}, ...
        'HorizontalAlignment','center', 'FontSize',16, 'ForegroundColor',.4*[1 1 1], ...
        'Unit','norm', 'Pos',[w1+w2+w3+w4+w5 0 w6 1]);
    
    wOK = .08;
    u = T.step(p);
    c1 = sprintf('h=findobj(''Tag'',''%s''); ',param);
    c2 = ['n=str2num(get(h,''str''))/' num2str(u) '; '];
    c3 = sprintf('cmd=tcs2.format_xxxx_command(''%s'',n,[%d %d]); ',T.cmd{p},T.min(p)/u,T.max(p)/u);
    c4 = sprintf('tcs2.write_serial(cmd);');
    uicontrol('Parent',pParams(p), 'Style','push', 'Str','OK', ...
        'Call',[c1 c2 c3 c4], ...
        'HorizontalAlignment','left', 'FontSize',14, 'FontWeight','bold', ...
        'Unit','norm', 'Pos',[1-wOK 0 wOK 1]);
end
