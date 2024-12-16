% Quick diagnostic of the zones of TCS for verification of the ramp-up speed and target temperature of each zones
% This routine works with the package "+tcs2" version '2.0.2'
% Material needed:
%       1 experiment PC (Matlab 2014a or later, depedning on the version visualization might be impacted)
%       1 TCS2
%
% This routine work for stimulation profil typically starting from baseline
% temperature to reach a target temperature and then back to baseline (3 segments in terms of stimulation profil)
% for more complex profil and sinusoidal stimulation thoeretical
% stimulation is disabled and only visuaal inspection is provided.
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
% Cédric Lenoir, COSY, IoNS, UCLouvain, May 2024
% Matlab 2023a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GUI for parameters
prompt = {'\fontsize{12} Test number :','\fontsize{12} Baseline temperature (°C) :', '\fontsize{12} Target temperature (from 0 to 65°C) :',...
        '\fontsize{12} Duration (rise time + plateau in ms) : ',...
        '\fontsize{12} Speed ramp-up (°C/s) : ', '\fontsize{12}  Speed ramp-down (°C/s) : ',...
        '\fontsize{12} For profil segment : Rise time (ms) : ',...
        '\fontsize{12} For profil segment : Plateau (ms) : ',...
        '\fontsize{12} For profil segment : Fall time (to baseline temperature in ms) : ',...
        '\fontsize{12} Which TCS (name) ?', '\fontsize{12} Which probe (name) ?','\fontsize{12} Which probe (type) ?',...
        '\fontsize{12} Enter comments'};
dlgtitle = 'Heating stimulation parameters';
opts.Interpreter = 'tex';
dims = repmat([1 80],13,1);
definput = {'1', '32', '62', '300', '300', '30', ' ', ' ', ' ', 'A', 'A', 'T03', 'none'};

info = inputdlg(prompt,dlgtitle,dims,definput,opts);
test_num = str2double(info(1)); 
baseline_temp = str2double(info(2)); % °C
target_temp = str2double(info(3)); % °C
duration = str2double(info(4)); % rise time + plateau (ms)
ramp_up = str2double(info(5)); % °C/s
ramp_down = str2double(info(6)); % °C/s
rise_time = str2double(info(7)); % ms
plateau_time = str2double(info(8)); % ms
fall_time = str2double(info(9)); % ms
% compute the different durations of the stimulation segments 
if isnan(rise_time)
    rise_time = abs((target_temp-baseline_temp))/(ramp_up/1000);
elseif ~isnan(rise_time)
    ramp_up = (abs((target_temp-baseline_temp))/rise_time)*1000;
    if ramp_up > 300
        disp('Heating ramp too high!')
        return
    end
end
if isnan(plateau_time) && ~isnan(duration)
    plateau_time = duration - rise_time;
else
end
if isnan(fall_time)
    fall_time = abs((target_temp-baseline_temp))/(ramp_down/1000);
elseif ~isnan(fall_time)
    ramp_down = (abs((target_temp-baseline_temp))/fall_time)*1000;
    if ramp_down > 300
        disp('Cooling ramp too high!')
        return
    end
end
if isnan(duration)
    duration = rise_time + plateau_time;
else
end

tcs = char(info(10));
probe = strcat(info(11),'-',info(12));
comments = info(13);

% add pre and post stimulus periods
pre_stim_dur = 10;
pst_stim_dur = 10;
pre_stim_temp = baseline_temp;
seg_duration = [pre_stim_dur rise_time/10 plateau_time/10 fall_time/10 pst_stim_dur];
seg_end_temp = [pre_stim_temp*10 target_temp*10 target_temp*10 baseline_temp*10 baseline_temp*10];

% create and save outcomes in .mat file
clockVal = clock; % Current date and time as date vector. [year month day hour minute seconds]
timestamp = sprintf('%d-%d-%d-%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6));
experiment = 'test_TCS2';
% make unique texte and mat filenames
txt_filename = strcat(['TCS2_',sprintf('%s', tcs),'_test_',sprintf('%s', num2str(test_num)), '_', sprintf('%s', timestamp),'.txt']);
mat_filename = strcat(['TCS2_',sprintf('%s', tcs),'_test_',sprintf('%s', num2str(test_num)), '_', sprintf('%s', timestamp),'.mat']);
% folder name to be done
current_folder = pwd;
% choose where to save the outcomes
chosen_dir = uigetdir(current_folder);
savePath = chosen_dir;

% % write in text file
% fidLog = fopen(fullfile(savePath,txt_filename),'w');
% fprintf(fidLog,'Experiment: %s \nDate and time: %s \nTest number: %s \nBaseline temperature: %s \nTarget temperature: %s \nTCS: %s; \nprobe: %s; \n\nNotes: %s \n\n',...
%     experiment, timestamp, num2str(test_num), num2str(baseline_temp), num2str(target_temp), char(tcs), char(probe), char(comments));

%%%%% add ramps and duration + store when done the parameters and diagnostic results %%%%%
test = struct;
test.param.pre_stim_dur = pre_stim_dur*10;
test.param.pst_stim_dur = pst_stim_dur*10;
test.param.pre_stim_temp = pre_stim_temp;
test.param.seg_duration = seg_duration;
test.param.seg_end_temp = seg_end_temp;
test.param.target_temp = target_temp;
test.param.duration = duration;
test.param.ramp_up = ramp_up;
test.param.ramp_down = ramp_down;
test.param.rise_time = rise_time;
test.param.plateau_time = plateau_time;
test.param.fall_time = fall_time;

% Initialization and communication
TCS_COM = tcs2.find_com_port;
pause(0.001)
COM = tcs2.init_serial(TCS_COM);
pause(0.001)

% verbosity
tcs2.verbose(1)

%%%%% add serial number of the TCS and probe + firmware version !!! %%%%% 
TCS_help = tcs2.get_help;
serial_numbers = TCS_help(2:85);

% check battery level and confirm
clc
tcs2.get_battery
disp('BATTERY OK ?')
disp('press key to continue !')
pause()

% set active areas
tcs2.set_active_areas(1:5)
pause(0.001)

% set neutral baseline temperature
tcs2.set_neutral_temperature(baseline_temp);
pause(0.001)

% set max temperature to 70 C°
tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 C°C !! Not available for all firwmare version.
pause(0.001)
tcs2.write_serial('Om700');
pause(0.001)

% set stimulation parameters using stimulation_profile
tcs2.enable_temperature_profil(11111)
pause(0.001)
areas = 11111;
num_seg = 5;
% build the stimulation profil with parameters + add pre-stimulus at baseline temeprature during 100 ms and post-stimulus at baseline temperature during 100 ms 
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp);

% enable temperature feedback at 100 Hz
tcs2.enable_temperature_feedback(100)
pause(0.001)

%%
% send stimulus
% loop of 10 stimulations
stim_number = 10;
zones = 5;
% prepare for storing of temperature data for 5 zones and successive 10 stimulations
temperature_feedback = cell(stim_number,zones);

for stim_num = 1:stim_number
    clc
    disp('Attention ! / be ready !')
    pause(1.5)
    tcs2.stimulate
    disp(strcat(['stimulation #',num2str(stim_num),' sent'])) 
    pause(1)
    clc
    if stim_num < 10
        disp(strcat(['move the probe for next stimulus']))
    elseif stim_num > 9
        disp(strcat(['done !']))
    end
    pause(1.5)

    % read temperature_feedback
    temporary = tcs2.read_serial;
    pause(2)
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
    for zones = 1:5
        temperature_feedback{stim_num,zones} = temp_feed(zones:5:end);
    end
    clear temporary temporary_index temp_feed 
end

test.results.feedback = temperature_feedback;

%% plot stimulus profil
% see sections in TCS_test_zones_plot

%% Checks
% pre-stimulus consistency
clc
for stim_num = 1:stim_number
    for zones = 1:5
        temp_base_pre{stim_num,zones} = temperature_feedback{stim_num,zones}(1:10);
        sd_base_pre(stim_num,zones) = std(temp_base_pre{stim_num,zones});
        mean_base_pre(stim_num,zones) = mean(temp_base_pre{stim_num,zones});
    end
end
for zones =1:5
    avg_sd_base_pre(1,zones) = mean(sd_base_pre(:,zones));
end
% warning per zone
for zones = 1:5
    % if avg_sd_base_pre(1,zones) <= 0.5 % std should be close to device precision
        mess_baseline_pre{zones} = strcat(['zone ',num2str(zones),' baseline pre stimulus is steady']);
        disp(mess_baseline_pre{zones});
    % else
         mess_baseline_pre{zones} = strcat(['WARNING ! zone ',num2str(zones),' baseline pre stimulus is not constant!']);
        disp(mess_baseline_pre{zones});
    % end
end

% find the zone with highest variability
[avg_sd_zone_pre, zone_pre] = max(avg_sd_base_pre);

test.results.avg_sd_base_pre = avg_sd_base_pre;
test.results.mean_base_pre = mean_base_pre;
test.results.zone_pre_variability = [avg_sd_zone_pre, zone_pre];

% line beak in command window
disp(' ')

% post-stimulus consistency
for stim_num = 1:stim_number
    for zones = 1:5
        temp_base_pst{stim_num,zones} = temperature_feedback{stim_num,zones}(end-9:end);
        sd_base_pst(stim_num,zones) = std(temp_base_pst{stim_num,zones});
        mean_base_pst(1,zones) = mean(temp_base_pst{stim_num,zones});
    end
end
for zones =1:5
    avg_sd_base_pst(1,zones) = mean(sd_base_pst(:,zones));
end
% warning per zone
for zones = 1:5
    if avg_sd_base_pst(1,zones) <= 0.5 % 0.5°C precision of the instrument
        mess_baseline_pst{zones} = strcat(['zone ',num2str(zones),' baseline post stimulus is steady']);
        disp(mess_baseline_pst{zones})
    else
        mess_baseline_pst{zones} = strcat(['WARNING! zone ',num2str(zones),' baseline post stimulus is not constant!']);
        disp(mess_baseline_pst{zones})
    end
end

% find the zone with highest variability
[avg_sd_zone_pst, zone_pst] = max(avg_sd_base_pst);

test.results.avg_sd_base_pst = avg_sd_base_pst;
test.results.mean_base_pst = mean_base_pst;
test.results.zone_pst_variability = [avg_sd_zone_pst, zone_pst];

% line beak in command window
disp(' ')

%% Ramp_up speed for each zone
% By default 2% of tolerance below the desired ramp up speed is allowed,
error = 0.02;
% x values for plotting
xvalues = (1:length(temperature_feedback{stim_num,zones}))*10;
x_rampup = xvalues(1:rise_time/10+1);
for stim_num = 1:stim_number
    for zones = 1:5
        rampup{stim_num,zones} = temperature_feedback{stim_num,zones}(10:(pre_stim_dur+rise_time/10));
        mdlup{stim_num,zones} = fitlm(x_rampup, rampup{stim_num,zones});
        slope_up(stim_num,zones) = round(table2array(mdlup{stim_num,zones}.Coefficients(2,1))*1000);
    end
end
for zones = 1:5
    avg_slope_up(1,zones) = mean(slope_up(:,zones));
    if avg_slope_up(1,zones) >= ramp_up*(1-error)
        mess_rampup{zones} = strcat(['ramp up @ zones ',num2str(zones),' is reached: ',num2str(round(avg_slope_up(1,zones))),' °C/s']);
        disp(mess_rampup{zones})
    else
        mess_rampup{zones} = strcat(['WARNING! ramp up @ zone ',num2str(zones),' is too low: ',num2str(round(avg_slope_up(1,zones))),' °C/s']);
        disp(mess_rampup{zones})
    end
end

% find the zone with highest variability
[min_slope_up, zone_up] = min(avg_slope_up);

test.results.avg_slope_up = avg_slope_up;
test.results.zone_min_slope_up = [min_slope_up, zone_up];

%% plot linear regression for each zone

%% overshoot
for stim_num = 1:stim_number
    for zones = 1:5
        overshoot(stim_num,zones) = temperature_feedback{stim_num,zones}(pre_stim_dur+1+rise_time/10);
        avg_overshoot(1,zones) = mean(overshoot(:,zones));
    end
end
% warning
for zones = 1:5
    if avg_overshoot(1,zones)- target_temp > 1
        mess_overshoot{zones} = strcat(['WARNING: max temperature exceeds target temperature @ zone ',num2str(zones)]);
        disp(mess_overshoot{zones});
    else
        mess_overshoot{zones} = 'OK';
    end
end

test.results.avg_overshoot = avg_overshoot;

%%  target temperature
for stim_num = 1:stim_number
    for zones = 1:5
        for bins = 1:(plateau_time/10)-1 % excluding overshoot
            plateau_temp{stim_num,zones}(bins) = temperature_feedback{stim_num,zones}(pre_stim_dur+bins+1+rise_time/10);
            sd_plateau_temp(stim_num,zones) = std(plateau_temp{stim_num,zones});
            avg_plateau_temp(stim_num,zones) = mean(plateau_temp{stim_num,zones});
        end
    end
end
for zones = 1:5
    avg_sd_plateau_temp(1,zones) = round(mean(sd_plateau_temp(:,zones)),2);
    avg_stim_plateau_temp(1,zones) = round(mean(avg_plateau_temp(:,zones)),1);
end

% find the zone with highest variability
[avg_sd_zone_plateau, zone_plat] = max(avg_sd_plateau_temp);
[min_avg_temp_zone_plateau, zone_temp_min] = min(avg_stim_plateau_temp);
[max_avg_temp_zone_plateau, zone_temp_max] = max(avg_stim_plateau_temp);

test.results.avg_sd_plateau_temp = avg_sd_plateau_temp;
test.results.avg_stim_plateau_temp = avg_stim_plateau_temp;
test.results.avg_sd_zone_plateau = avg_sd_zone_plateau;
test.results.min_avg_temp_zone_plateau = min_avg_temp_zone_plateau;
test.results.max_avg_temp_zone_plateau = max_avg_temp_zone_plateau;

%% Ramp_down speed for each zone
% By default 2% of tolerance below the desired ramp down speed is allowed,
% this can be changed using the error parameter below
error = 0.02;
x_rampdwn = xvalues(1:fall_time/10+1);

% line beak in command window
disp(' ')

for stim_num = 1:stim_number
    for zones = 1:5
        rampdwn{stim_num,zones} = temperature_feedback{stim_num,zones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
        mdldwn{stim_num,zones} = fitlm(x_rampdwn, rampdwn{stim_num,zones});
        slope_dwn(stim_num,zones) = abs(round(table2array(mdldwn{stim_num,zones}.Coefficients(2,1))*1000));
    end
end
for zones = 1:5
    avg_slope_dwn(1,zones) = mean(slope_dwn(:,zones));
    if avg_slope_dwn(1,zones) >= ramp_down*(1-error)
        mess_rampdwn{zones} = strcat(['ramp down @ zones ',num2str(zones),' is reached: ',num2str(round(avg_slope_dwn(1,zones))),' °C/s']);
        disp(mess_rampdwn{zones})
    else
        mess_rampdwn{zones} = strcat(['WARNING! ramp down @ zone ',num2str(zones),' is too low: ',num2str(round(avg_slope_dwn(1,zones))),' °C/s']);
        disp(mess_rampdwn{zones})
    end
end

test.results.avg_slope_dwn = avg_slope_dwn;

%% save
% write param in text file
fidLog = fopen(fullfile(savePath,txt_filename),'w');
fprintf(fidLog,'TEST: %s \n\nDate and time: %s \n\nTest number: %s \n\nTCS: %s \n\nfirmware & probe: %s \n\nBaseline temperature: %s°C \n\nTarget temperature: %s°C \n\nRamp-up speed: %s°C/s \n\nRamp-down: %s°C/s \n\nNotes: %s \n\n',...
    experiment, timestamp, num2str(test_num), tcs, serial_numbers, num2str(baseline_temp), num2str(target_temp), num2str(ramp_up), num2str(ramp_down), char(comments));

% write results in text file
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'--------------- \n RESULTS \n baseline pre stim:');
for zones = 1:5
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pre{zones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n baseline post stim:');
for zones = 1:5
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pst{zones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp up:');
for zones = 1:5
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampup{zones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n overshoot:');
for zones = 1:5
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_overshoot{zones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp down:');
for zones = 1:5
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampdwn{zones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');


% save outcomes of the test
save(fullfile(savePath,mat_filename), 'test')





