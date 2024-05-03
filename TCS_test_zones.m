% Quick diagnostic of the zones of TCS for verification of the ramp-up speed and target temperature of each zones
% This routine works with the package "+tcs2" version '2.0.2'
% Material needed: 1 experiment PC (Matlab 2014a or later), 1 TCS2
%
% First: fill in the GUI with stimulation parameters 
% Second: follow instructions and deliver the stimulations onto the skin,
% move the probe when you hear a bip
% Third: a plot and some basic statistics are provided to evaluate of the
% zones deliver the stimulation properly
% 
% TCS and probe names are A, B, C, D, or E
% TCS probe type are "classic" T03, "5 Peltier in a row" T01, "large as
% Medoc thermode T11", "MRI" T09 etc (see QSTLab website)
%
%
% CÃ©dric Lenoir, COSY, IoNS, UCLouvain, May 2024
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GUI for parameters
prompt = {'\fontsize{12} Test number :','\fontsize{12} Baseline temperature (Â°C) :', '\fontsize{12} Target temperature (Â°C) :',...
        '\fontsize{12} Plateau duration (ms) : ',...
        '\fontsize{12} Speed ramp-up (Â°C/s) : ', '\fontsize{12}  Speed ramp-down (Â°C/s) : ',...
        '\fontsize{12} Which TCS (name) ?', '\fontsize{12} Which probe (name) ?','\fontsize{12} Which probe (type) ?',...
        '\fontsize{12} Enter comments'};
dlgtitle = 'Stimulation parameters';
opts.Interpreter = 'tex';
dims = repmat([1 60],10,1);
definput = {'1', '32', '62', '200', '300', '30', ' ', ' ', ' ', ' '};

info = inputdlg(prompt,dlgtitle,dims,definput,opts);
test_num = str2double(info(1)); 
baseline_temp = str2double(info(2)); % °C
target_temp = str2double(info(3)); % °C
duration = str2double(info(4)); % ms
ramp_up = str2double(info(5)); % °C/s
ramp_down = str2double(info(6)); % °C/s
tcs = info(7);
probe = strcat(info(8),'-',info(9));
comments = info(10);

% TCS_DURATION = 250; % ms
% TCS_RAMP_UP = 300; % °C/s
% TCS_reftemp = 62;
% TCS_neutraltemp = 35;
% TCS_delta_temp = TCS_reftemp-TCS_neutraltemp;
% ramp_up_time = (TCS_delta_temp/TCS_RAMP_UP)*1000;


% create and save outcomes in .mat file
clockVal = clock; % Current date and time as date vector. [year month day hour minute seconds]
timestamp = sprintf('%d-%d-%d-%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6));
experiment = 'test_TCS2';
% make unique texte and mat filenames
txt_filename = strcat(['test-',sprintf('%s', num2str(test_num)), ' on ', sprintf('%s', timestamp),'.txt']);
mat_filename = strcat(['test-',sprintf('%s', num2str(test_num)), ' on ', sprintf('%s', timestamp),'.txt']);
% folder name to be done
current_folder = pwd;
% choose where to save the outcomes
chosen_dir = uigetdir(current_folder);
savePath = chosen_dir;

% write in text file
fidLog = fopen(fullfile(savePath,txt_filename),'w');
fprintf(fidLog,'Experiment: %s \nDate and time: %s \nTest number: %s \nBaseline temperature: %s \nTarget temperature: %s \nTCS: %s; \nprobe: %s; \n\nNotes: %s \n\n',...
    experiment, timestamp, num2str(test_num), num2str(baseline_temp), num2str(target_temp), char(tcs), char(probe), char(comments));
%%%%% add ramps and duration + store when done the parameters and diagnostic results %%%%%

% Initialization and communication
TCS_COM = tcs2.find_com_port;
COM = tcs2.init_serial(TCS_COM);
pause(0.1)

% verbosity
tcs2.verbose(2)

% check battery level and confirm
clc
tcs2.get_battery
disp('BATTERY OK ?')
disp('press key to continue !')
pause()

% set active areas
tcs2.set_active_areas(1:5)
pause(0.1)

% set neutral baseline temperature
tcs2.set_neutral_temperature(baseline_temp);
pause(0.1)

% set max temperature to 70 C°
tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 C°C !! Not available for all firwmare version.
tcs2.write_serial('Om700');
pause(0.1)

% set stimulation
% tcs2.set_stim_duration(duration,ramp_up,ramp_down)
% pause(0.1)
% tcs2.set_stim_temperature(target_temp)
% pause(0.1)

%%%%%%%%%%% alternative using profile
tcs2.enable_temperature_profil(11111)
pause(0.1)
areas = 11111;
num_seg = 3;
seg_duration = [10 20 999];
seg_end_temp = [target_temp*10 target_temp*10 baseline_temp*10];
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp)

% enable temperature feedback at 100 Hz
tcs2.enable_temperature_feedback(100)
pause(0.1)

%%
% send stimulus
tcs2.stimulate
pause(4)
% temperature_feedback
temporary = tcs2.read_serial;              % Extract raw data from TCS
%%
% preallocation for speed purposes
temperature_feedback = cell(1,5); % Temperature data will be stored here.
% disp('Extracting temperature feedback...')
% tcs2.current_serial(com)
temporary_index = strfind(temporary,'+');   % Extract position of temperature data from raw data
temp_feed = zeros(1,length(temporary_index)); % Preallocation for speed purposes

% Extract and store temperature data in a cell array
for a = 1:length(temporary_index)
    temp_feed(a) = str2double(temporary(temporary_index(a)+1:temporary_index(a)+4));
end

% This should match the current stimulation number (probably the loop variable)
stimulation_number = 1;
for b = 1:5
    temperature_feedback{stimulation_number,b} = temp_feed(b:5:end);
end

% plot
F = figure('Position',[0,0,1000,900]);
color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
xvalues = (1:length(temperature_feedback{1}))*10;
hold on
for c = 1:5
   plot(xvalues,temperature_feedback{stimulation_number,c},'Color',color_plot{c},'LineWidth',1.5)
   hold on
end
hold on
% plot theoretical stimulation profil
% plot([10 ramp_up_time+10 TCS_DURATION+10],[TCS_neutraltemp TCS_reftemp TCS_reftemp],'--k')

% layout
set(gca,'FontSize',12)
set(gca,'YTick',(baseline_temp:1:target_temp+3))
set(gca,'TickDir','out')
title(['temperature curve for ', 'stimulation at ',num2str(target_temp),'°C'],'FontSize',15);
L = legend('1','2','3','4','5',' ');
set(L,'Box','off')
xlabel('time (ms)')
ylabel('temperature (°C)')
ax = gca;
ax.Box = 'off';
set(gcf,'Color','w')










