% tcs2.test_profile plots the requested and delivered stimulation profiles.
% Results are saved in a structure 'test' in a .mat file and a Matlab figure is saved.
% 
% This routine is part of the package "+tcs2" version 3.0.
% 
% Material needed:
%         1 experiment laptop (Matlab 2014a or later up to 2023b)
%         1 TCS2 + probe
%         Apply stimulation on the skin!
% 
% This function works for basic stimulation profile typically starting from baseline temperature,
% then reaching a target temperature and then going back to baseline (5 segments in terms of stimulation profile).
% More complex profil (e.g. sinusoidal stimulation) are not included here.
% 
% First: fill in the GUI with stimulation parameters (except pre and post
% stimulus periods that are fixed).
% Second: follow instructions and deliver the stimulation onto the skin.
% Third: figure will pop up and parameters and figure are saved in the folder of your choice. 
% 
% TCS and probe names are A, B, C, D, or E.
% 
% 
% Cédric Lenoir, MINT, IoNS, UCLouvain, January 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_profile

%%% TCS communication
TCS_COM = tcs2.find_com_port;
pause(0.001)
serialObj = tcs2.init_serial(TCS_COM);
pause(0.001)

% verbosity
tcs2.verbose(1)

% set TCS to mute mode
tcs2.disable_temperature_feedback
% empty the serial communication
tcs2.clear_serial

% get the firmware version number, serial no. and type of the probe
TCS_help = tcs2.get_serial_cmd_help;
serial_number = TCS_help(2:85);
probe_type = serial_number(end-2:end);

% set the ramp-up and -down limit dependong on the probe
if strcmp(probe_type, '003')
    ramp_limit = 300;
elseif strcmp(probe_type, '109')
    ramp_limit = 75; % 50°C/s if filter high
    pause(0.001)
elseif strcmp(probe_type, '111')
    ramp_limit = 75; % 50°C/s if filter high
    pause(0.001)
end

% get +tcs2 package version
ver = tcs2.get_version;
pause(0.001)
% % check battery level and confirm
% clc
% tcs2.get_battery(1)
% resp = input('BATTERY OK ? [y/n] ','s');
% if strcmp(resp,'n')
%     return
% else
% end


%%% GUI for parameters
prompt = {'\fontsize{12} User Name :','\fontsize{12} Which TCS (A,B,C,...) :',...
    '\fontsize{12} Which probe (A,B,C,...) :','\fontsize{12} Comments :',...
    '\fontsize{12} Neutral temperature (°C) :','\fontsize{12} Target temperature (°C) :',... 
    '\fontsize{12} Duration (rise time + plateau in ms) : ',...
    '\fontsize{12} Speed ramp-up (°C/s) : ', '\fontsize{12}  Speed ramp-down (°C/s) : ',...
    '\fontsize{12} For profil segment : Rise time (to target temperature in ms) : ',...
    '\fontsize{12} For profil segment : Plateau (ms) : ',...
    '\fontsize{12} For profil segment : Down time (to neutral temperature in ms) : '...
    '\fontsize{12} Active areas (xxxxx with x=0/1) : '};
dlgtitle = 'Heat stimulation parameters';
opts.Interpreter = 'tex';
dims = repmat([1 80],13,1);
definput = {'', '', '', 'none', '', '', '', '', '', '', '', '','11111'};
info = inputdlg(prompt,dlgtitle,dims,definput,opts);
user_name = char(info(1));
TCS_name = char(info(2));
TCS_name = strrep(TCS_name,' ','');
probe_name = char(info(3));
probe_name = strrep(probe_name,' ','');
comments = char(info(4));
baseline_temp = str2double(info(5)); % °C
target_temp = str2double(info(6)); % °C
duration = str2double(info(7)); % ms
ramp_up = str2double(info(8)); % °C/s
ramp_down = str2double(info(9)); % °C/s
rise_time = str2double(info(10)); % ms
plateau_time = str2double(info(11)); % ms
down_time = str2double(info(12)); % ms
areas = str2double(info(13));


%%% Additional parameters
% number of stimuli
stim_number = 1;
% active zones of the thermode
zones = 5;
% local function roundn for round to be compatible with all Matlab versions
roundn = @(x,n) round(x.*10.^n)./10.^n;

% warning message if missing argument
if isnan(rise_time) && isnan(ramp_up)
    error('Missing arguments, specify at least rise time or heating ramp!')
else
end
if isnan(duration) && isnan(plateau_time)
    error('Missing arguments, specify at least duration (=rise time + plateau) or plateau time!')
else
end
% compute the different durations of the stimulation segments 
if isnan(rise_time)
    rise_time = abs((target_temp-baseline_temp))/(ramp_up/1000);
elseif ~isnan(rise_time)
    ramp_up = (abs((target_temp-baseline_temp))/rise_time)*1000;
    % check if heating ramp is within probe limitation
    if ramp_up > ramp_limit
        disp('Heating ramp too high! adjust stimulation parameters.')
        return
    end
end
if isnan(plateau_time)
    plateau_time = duration - rise_time;
else
end
if isnan(down_time)
    down_time = abs((target_temp-baseline_temp))/(ramp_down/1000);
elseif ~isnan(down_time)
    ramp_down = (abs((target_temp-baseline_temp))/down_time)*1000;
    % check if cooling ramp is within probe limitation
    if ramp_down > ramp_limit
        disp('Cooling ramp too high! adjust stimulation parameters.')
        return
    end
end
if isnan(duration)
    duration = rise_time + plateau_time;
else
end
% add pre and post stimulus periods of 100 ms
pre_stim_dur = 100;
pst_stim_dur = 500;
pre_stim_temp = baseline_temp;
seg_duration = [pre_stim_dur rise_time plateau_time down_time pst_stim_dur];
seg_end_temp = [pre_stim_temp target_temp target_temp baseline_temp baseline_temp];


%%% structure for parameters and results
test = struct;
test.param.probe = probe_type;
test.param.pre_stim_dur = pre_stim_dur;
test.param.pst_stim_dur = pst_stim_dur;
test.param.pre_stim_temp = pre_stim_temp;
test.param.seg_duration = seg_duration;
test.param.seg_end_temp = seg_end_temp;
test.param.target_temp = target_temp;
test.param.duration = duration;
test.param.ramp_up = ramp_up;
test.param.ramp_down = ramp_down;
test.param.rise_time = rise_time;
test.param.plateau_time = plateau_time;
test.param.fall_time = down_time;
test.param.areas = areas;

%%% create paths to save outcomes in .mat and .txt files
clockVal = clock; % Current date and time as date vector. [year month day hour minute seconds]
timestamp = sprintf('%d-%d-%d-%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6));
experiment = 'test_TCS2';
% make unique texte and mat filenames
txt_filename = strcat(['Profile_TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.txt']);
% mat_filename = strcat(['TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.mat']);
fig_filename = strcat(['Profile_TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.fig']);
% results files will be save in the folder of your choice
current_folder = pwd;
chosen_dir = uigetdir(current_folder,'Select folder to save test results');
savePath = chosen_dir;


%%% Initialization of the TCS and stimulation parameters
% set ctive areas
tcs2.set_active_areas(areas)
pause(0.001)

% set neutral baseline temperature
tcs2.set_neutral_temperature(baseline_temp);
pause(0.001)

% set max temperature to 70 C°
% tcs2.set_max_temperature(70); % hidden command to allow stimulation up to 70 C°C !! Not available for all firwmare version.
pause(0.001)

% set stimulation parameters using stimulation_profile
tcs2.enable_temperature_profile(areas)
pause(0.001)
num_seg = 5;
% build the stimulation profil with parameters + add pre-stimulus at baseline temeprature during 100 ms and post-stimulus at baseline temperature during 100 ms 
tcs2.set_stim_profile(areas,num_seg,seg_duration,seg_end_temp);
pause(0.001)
% enable temperature feedback at 100 Hz
tcs2.enable_temperature_feedback(100)
pause(0.001)


%%% Send stimulus and get feedback
% prepare for storing of temperature data for 5 zones
temperature_feedback = cell(stim_number,zones);

clc
disp('PUT the probe on the gel pad.')
disp('PRESS ANY KEY TO START STIMULATION.')
pause()
disp('Do not move... Attention ! / Be ready !')
pause(1.5)
tcs2.stimulate
disp(strcat(['stimulation sent']))
pause((duration+down_time+pre_stim_dur+pst_stim_dur)/1000)
disp('Stimulations done! Results will appear...')
pause(1.5)

% read temperature_feedback
temporary = tcs2.read_serial;
pause(3)
tcs2.clear_serial;

% extract position of separators in the char temperature data
temporary_index = strfind(temporary,'+');

% preallocation for speed purposes
temp_feed = zeros(1,length(temporary_index));

% store temperature data in a cell array
for idx = 1:length(temporary_index)
    temp_feed(idx) = str2double(temporary(temporary_index(idx)+1:temporary_index(idx)+4));
end
% sort the temperatures according to each zones (1 to 5)
for izone = 1:zones
    temperature_feedback{izone} = temp_feed(izone:5:end);
end

test.results.feedback = temperature_feedback;


%%% write param in text file
fidLog = fopen(fullfile(savePath,txt_filename),'w');
fprintf(fidLog,'TEST: %s \nPackage version: %s \nDate and time: %s \nUser name: %s \n\nTCS: %s \nProbe name: %s \n%s \n\nBaseline temperature: %s°C \nTarget temperature: %s°C \nRamp-up speed: %s°C/s \nRamp-down: %s°C/s \n\nNotes: %s \n\n',...
    experiment, ver, timestamp, user_name, TCS_name, probe_name, serial_number, num2str(baseline_temp), num2str(target_temp), num2str(ramp_up), num2str(ramp_down), char(comments));


%%% plot feedback
F1 = figure('color','w','Position',[0,0,1000,900]);
color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
xvalues = ((1:length(temperature_feedback{stim_number,zones}))*10);

% plot theoretical stimulation profile
x_val = cumsum([0 test.param.pre_stim_dur test.param.rise_time test.param.plateau_time test.param.fall_time test.param.pst_stim_dur]);
y_val = [test.param.pre_stim_temp test.param.pre_stim_temp test.param.target_temp test.param.target_temp test.param.pre_stim_temp test.param.pre_stim_temp];

pt = plot(x_val,y_val,'--m','LineWidth',1.5);
hold on

for izone = 1:zones
  z_temperature_feedback(izone,:) = temperature_feedback{izone};
end
for izone = 1:zones
    pz{izone} = plot(xvalues,z_temperature_feedback(izone,:),'Color',color_plot{izone},'LineWidth',1);
    hold on
end

% plotting layout
set(gca,'FontSize',12)
set(gca,'YTick',(test.param.pre_stim_temp:1:test.param.target_temp+3))
set(gca,'TickDir','out')
title(['Profile temperature ', '(',num2str(test.param.target_temp),'°C)'],'FontSize',15);
xlabel('time (ms)')
ylabel('temperature (°C)')
ax = gca;
ax.Box = 'off';
ax.XLim = [0 (duration+down_time+pre_stim_dur+pst_stim_dur)];
ax.YLim = [baseline_temp-3 target_temp+3];
y1 = yline(target_temp,'--k');
y2 = yline(baseline_temp,'--k');
L = legend([pt pz{1,1:5}], 'theoretical','zone 1','zone 2','zone 3','zone 4','zone 5');
set(L,'Box','off','Location','best')

%%% save outcomes of the test
save(fullfile(savePath,txt_filename), 'test')
saveas(F1,fullfile(savePath,fig_filename),'fig')
close all; fclose all; clear
tcs2.close_serial(serialObj)

disp('Data saved in zip file, PLEASE SEND IT TO MINT :-)')
end