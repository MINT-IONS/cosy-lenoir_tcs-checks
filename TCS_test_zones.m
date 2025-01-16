% tcs2.TCS_test-zones.m  performs the quick routine check of the device.
% Results are saved in a structure in a .mat file and a summary of parameters and results are saved in a .txt file. Both files are then stored in an archive .zip file. 
% 
% This routine works with the package "+tcs2" version '3.0’
% 
% Material needed:
%         1 experiment laptop (Matlab 2014a or later up to 2023b)
%         1 TCS2 + probe
% 
% This routine works for basic stimulation profile typically starting from baseline temperature then reaching a target temperature and then going back to baseline (5 segments in terms of stimulation profile). More complex profil (e.g. sinusoidal stimulation) are not included here.
% 
% First: fill in the GUI with stimulation parameters 
% Second: follow instructions and deliver the stimulations onto the skin, move the probe at each beep!
% Third: some basic statistics are provided to assess if the thermode delivered properly the requested heat stimulation. 
% Fourth: send the output files to MINT !
% 
% TCS and probe names are A, B, C, D, or E.
% 
% Visualization of the results could be easily done using TCS_test_zones_plot.m
% 
% Cédric Lenoir, MINT, IoNS, UCLouvain, January 2025
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TCS_test_zones

% GUI for parameters
prompt = {'\fontsize{12} User Name :','\fontsize{12} Baseline temperature (°C) :', '\fontsize{12} Target temperature (from 0 to 65°C) :',...
        '\fontsize{12} Duration (rise time + plateau in ms) : ',...
        '\fontsize{12} Speed ramp-up (°C/s) : ', '\fontsize{12}  Speed ramp-down (°C/s) : ',...
        '\fontsize{12} For profil segment : Rise time (ms) : ',...
        '\fontsize{12} For profil segment : Plateau (ms) : ',...
        '\fontsize{12} For profil segment : Fall time (to baseline temperature in ms) : ',...
        '\fontsize{12} Which TCS (name) ?', '\fontsize{12} Which probe (name) ?',...
        '\fontsize{12} Enter comments'};
dlgtitle = 'Heat stimulation parameters';
opts.Interpreter = 'tex';
dims = repmat([1 80],12,1);
definput = {'', '32', '62', '300', '300', '300', '', '', '', '', '', 'none'};

info = inputdlg(prompt,dlgtitle,dims,definput,opts);
user_name = char(info(1));
baseline_temp = str2double(info(2)); % °C
target_temp = str2double(info(3)); % °C
duration = str2double(info(4)); % rise time + plateau (ms)
ramp_up = str2double(info(5)); % °C/s
ramp_down = str2double(info(6)); % °C/s
rise_time = str2double(info(7)); % ms
plateau_time = str2double(info(8)); % ms
fall_time = str2double(info(9)); % ms
TCS_name = char(info(10));
TCS_name = strrep(TCS_name,' ','');
probe_name = char(info(11));
probe_name = strrep(probe_name,' ','');
comments = info(12);

% number of stimuli
stim_number = 10;
% active zones of the thermode
zones = 5;

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

% add pre and post stimulus periods
pre_stim_dur = 10;
pst_stim_dur = 10;
pre_stim_temp = baseline_temp;
seg_duration = [pre_stim_dur rise_time plateau_time fall_time pst_stim_dur];
seg_end_temp = [pre_stim_temp target_temp target_temp baseline_temp baseline_temp];

% create and save outcomes in .mat file
clockVal = clock; % Current date and time as date vector. [year month day hour minute seconds]
timestamp = sprintf('%d-%d-%d-%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6));
experiment = 'test_TCS2';
% make unique texte and mat filenames
txt_filename = strcat(['TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.txt']);
mat_filename = strcat(['TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.mat']);
% default files will be save on the desktop (alternatively choice where to
% % save the outcomes)
% chosen_dir = uigetdir(current_folder);
% savePath = chosen_dir;
savePath = 'C:\Users\Nocions\Desktop';

%%%%% add ramps and duration + store when done the parameters and diagnostic results %%%%%
test = struct;
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
test.param.fall_time = fall_time;

% Initialization and communication
TCS_COM = tcs2.find_com_port;
pause(0.001)
serialObj = tcs2.init_serial(TCS_COM);
pause(0.001)

% verbosity
tcs2.verbose(1)

% get the firmware version number and serial no. of the probe
TCS_help = tcs2.get_serial_cmd_help;
serial_number = TCS_help(2:95);

% get +tcs2 package version
ver = tcs2.get_version;

% check battery level and confirm
clc
tcs2.get_battery(1)
disp('BATTERY OK ?')
disp('press key to continue !')
pause()

% set all active areas
areas = 11111;
tcs2.set_active_areas(areas)
pause(0.001)

% set neutral baseline temperature
tcs2.set_neutral_temperature(baseline_temp);
pause(0.001)

% set max temperature to 70 C°
tcs2.set_maximum_temp(70); % hidden command to allow stimulation up to 70 C°C !! Not available for all firwmare version.
pause(0.001)

% set stimulation parameters using stimulation_profile
tcs2.enable_temperature_profil(areas)
pause(0.001)
num_seg = 5;
% build the stimulation profil with parameters + add pre-stimulus at baseline temeprature during 100 ms and post-stimulus at baseline temperature during 100 ms 
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp);
pause(0.001)
% enable temperature feedback at 100 Hz
tcs2.enable_temperature_feedback(100)
pause(0.001)

%% loop to send stimuli

% prepare for storing of temperature data for 5 zones and successive 10 stimulations
temperature_feedback = cell(stim_number,zones);

for stim_num = 1:stim_number
    clc
    disp('Attention ! / be ready !')
    pause(1.5)
    tcs2.stimulate
    disp(strcat(['stimulation #',num2str(stim_num),' /',num2str(stim_number),' sent'])) 
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
    for izones = 1:zones
        temperature_feedback{stim_num,izones} = temp_feed(izones:5:end);
    end
    clear temporary temporary_index temp_feed 
end

test.results.feedback = temperature_feedback;

%% plot stimulus profil
% see TCS_test_zones_plot.m

%% Checks
% pre-stimulus consistency
clc
for stim_num = 1:stim_number
    for izones = 1:zones
        temp_base_pre{stim_num,izones} = temperature_feedback{stim_num,izones}(1:10);
        sd_base_pre(stim_num,izones) = std(temp_base_pre{stim_num,izones});
        mean_base_pre(stim_num,izones) = mean(temp_base_pre{stim_num,izones});
    end
end
for izones = 1:zones
    avg_sd_base_pre(1,izones) = mean(sd_base_pre(:,izones));
end
% warning per zone
for izones = 1:zones
    if avg_sd_base_pre(1,izones) <= 0.1  % 0.1°C relative accuracy of the TCS
        mess_baseline_pre{izones} = strcat(['zone ',num2str(izones),' neutral temperature pre-stimulus is steady']);
        disp(mess_baseline_pre{izones});
    else
         mess_baseline_pre{izones} = strcat(['WARNING! zone ',num2str(izones),' neutral temperature pre-stimulus is not constant!']);
        disp(mess_baseline_pre{izones});
    end
end

% find the zone with highest variability
[avg_sd_zone_pre, zone_pre] = max(avg_sd_base_pre);
test.results.avg_sd_base_pre = avg_sd_base_pre;
test.results.mean_base_pre = mean_base_pre;
test.results.zone_pre_variability = [avg_sd_zone_pre, zone_pre];

% linebreak in command window
disp(' ')

% post-stimulus consistency
for stim_num = 1:stim_number
    for izones = 1:zones
        temp_base_pst{stim_num,izones} = temperature_feedback{stim_num,izones}(end-9:end);
        sd_base_pst(stim_num,izones) = std(temp_base_pst{stim_num,izones});
        mean_base_pst(1,izones) = mean(temp_base_pst{stim_num,izones});
    end
end
for izones = 1:zones
    avg_sd_base_pst(1,izones) = mean(sd_base_pst(:,izones));
end
% warning per zone
for izones = 1:zones
    if avg_sd_base_pst(1,izones) <= 0.1 % 0.1°C relative accuracy of the TCS
        mess_baseline_pst{izones} = strcat(['zone ',num2str(izones),' neutral temperature post-stimulus is steady']);
        disp(mess_baseline_pst{izones})
    else
        mess_baseline_pst{izones} = strcat(['WARNING! zone ',num2str(izones),' neutral temperature post-stimulus is not constant!']);
        disp(mess_baseline_pst{izones})
    end
end

% find the zone with highest variability
[avg_sd_zone_pst, zone_pst] = max(avg_sd_base_pst);

test.results.avg_sd_base_pst = avg_sd_base_pst;
test.results.mean_base_pst = mean_base_pst;
test.results.zone_pst_variability = [avg_sd_zone_pst, zone_pst];

% linebreak in command window
disp(' ')

%% Ramp_up speed for each stim and zone

% x values for plotting and linear regression
xvalues = (1:length(temperature_feedback{stim_number,zones}))*10;
x_rampup = xvalues(1:rise_time/10+1);

%%% variability at trial level %%%
for izones = 1:zones
    for stim_num = 1:stim_number
        rampup{stim_num,izones} = temperature_feedback{stim_num,izones}(10:(pre_stim_dur+rise_time/10));
        mdlup{stim_num,izones} = fitlm(x_rampup, rampup{stim_num,izones});
        trial_slope_up(stim_num,izones) = round(table2array(mdlup{stim_num,izones}.Coefficients(2,1))*1000);
    end
end

for izones = 1:zones
    avg_slope_up(1,izones) = mean(trial_slope_up(:,izones));
    std_slope_up(1,izones) = std(trial_slope_up(:,izones));
end

% find the zone with slowest slope
[min_slope_up, min_zone_up] = min(avg_slope_up);

% find the zone with highest slope variability
for izones = 1:zones
    std_slope_up(1,izones) = std(trial_slope_up(:,izones));
end
[max_std_slope_up, max_std_zone_up] = max(std_slope_up);

test.results.avg_slope_up = avg_slope_up;
test.results.std_slope_up = std_slope_up;
test.results.zone_min_slope_up = [min_slope_up, min_zone_up];
test.results.zone_max_std_slope_up = [max_std_slope_up, max_std_zone_up];

%%% estimation at zone level on averaged trials %%%
for izones = 1:zones
    switch izones
        case 1
            for istim = 1:stim_num
                z1_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izones}(10:(pre_stim_dur+rise_time/10));
            end
            avg_rampup_temp_feedb(izones,:) = mean(z1_rampup_temp_feedb);
        case 2
            for istim = 1:stim_num
                z2_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izones}(10:(pre_stim_dur+rise_time/10));
            end
            avg_rampup_temp_feedb(izones,:) = mean(z2_rampup_temp_feedb);
        case 3
            for istim = 1:stim_num
                z3_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izones}(10:(pre_stim_dur+rise_time/10));
            end
            avg_rampup_temp_feedb(izones,:) = mean(z3_rampup_temp_feedb);
        case 4
            for istim = 1:stim_num
                z4_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izones}(10:(pre_stim_dur+rise_time/10));
            end
            avg_rampup_temp_feedb(izones,:) = mean(z4_rampup_temp_feedb);
        case 5
            for istim = 1:stim_num
                z5_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izones}(10:(pre_stim_dur+rise_time/10));
            end
            avg_rampup_temp_feedb(izones,:) = mean(z5_rampup_temp_feedb);
    end
end

% warning if slopes are below tolerance level
ramp_tolerance = 0.02; % 2% arbitrary

for izones = 1:zones
    zone_mdlup{izones} = fitlm(x_rampup, avg_rampup_temp_feedb(izones,:));
    zone_slope_up(izones) = round(table2array(zone_mdlup{izones}.Coefficients(2,1))*1000);
    if zone_slope_up(1,izones) >= ramp_up*(1-ramp_tolerance)
        mess_rampup{izones} = strcat(['ramp up @ zones ',num2str(izones),' is reached: ',num2str(round(avg_slope_up(1,izones))),' °C/s']);
        disp(mess_rampup{izones})
    else
        mess_rampup{izones} = strcat(['WARNING! ramp up @ zone ',num2str(izones),' is too low: ',num2str(round(avg_slope_up(1,izones))),' °C/s']);
        disp(mess_rampup{izones})
    end
end

test.results.zone_slope_up = zone_slope_up;

% linebreak in command window
disp(' ')

%% plot linear regression for each zone

%% overshoot
for stim_num = 1:stim_number
    for izones = 1:zones
        overshoot(stim_num,izones) = temperature_feedback{stim_num,izones}(pre_stim_dur+1+rise_time/10);
        avg_overshoot(1,izones) = mean(overshoot(:,izones));
        std_overshoot(1,izones) = std(overshoot(:,izones));
    end
end

% warning
for izones = 1:zones
    if avg_overshoot(1,izones)- target_temp > 1
        mess_overshoot{izones} = strcat(['WARNING! max temperature ',num2str(avg_overshoot(1,izones)- target_temp),'°C above target temperature @ zone ',num2str(izones)]);
        disp(mess_overshoot{izones});
    else
        mess_overshoot{izones} = strcat(['overshoot @ zone ',num2str(izones),' below 1°C']);
        disp(mess_overshoot{izones});
    end
end

% variability of overshoot per zone
[max_std_overshoot, max_std_zone_overshoot] = max(std_overshoot);

test.results.avg_overshoot = avg_overshoot;
test.results.std_overshoot = std_overshoot;
test.results.max_std_overshoot = max_std_overshoot;
test.results.max_std_zone_overshoot = max_std_zone_overshoot;

% linebreak in command window
disp(' ')

%%  target temperature
for stim_num = 1:stim_number
    for izones = 1:zones
        for bins = 1:(plateau_time/10)-1
            plateau_temp{stim_num,izones}(bins) = temperature_feedback{stim_num,izones}(pre_stim_dur+bins+1+rise_time/10); % excluding overshoot
            sd_plateau_temp(stim_num,izones) = std(plateau_temp{stim_num,izones});
            avg_plateau_temp(stim_num,izones) = mean(plateau_temp{stim_num,izones});
        end
    end
end
for izones = 1:zones
    avg_sd_plateau_temp(1,izones) = round(mean(sd_plateau_temp(:,izones)),2);
    avg_stim_plateau_temp(1,izones) = round(mean(avg_plateau_temp(:,izones)),1);
end

% warning per zone
for izones = 1:zones
    if avg_sd_plateau_temp(1,izones) <= 0.2 % 0.2°C given the recovery after overshoot (0.1°C relative accuracy of the TCS)
        mess_plateau_temp{izones} = strcat(['plateau temperature is steady @ zone ',num2str(izones)]);
        disp(mess_plateau_temp{izones})
    else
        mess_plateau_temp{izones} = strcat(['WARNING! zone ',num2str(izones),' plateau temperature is not constant!']);
        disp(mess_plateau_temp{izones})
    end
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

% linebreak in command window
disp(' ')

%% Ramp_down speed for each zone

% x values for plotting and linear regression
x_rampdwn = xvalues(1:fall_time/10+1);

%%% variability at trial level %%%
for izones = 1:zones
    for stim_num = 1:stim_number
        rampdwn{stim_num,izones} = temperature_feedback{stim_num,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
        mdldwn{stim_num,izones} = fitlm(x_rampdwn, rampdwn{stim_num,izones});
        trial_slope_dwn(stim_num,izones) = abs(round(table2array(mdldwn{stim_num,izones}.Coefficients(2,1))*1000));
    end
end
for izones = 1:zones
    avg_slope_dwn(1,izones) = mean(trial_slope_dwn(:,izones));
    std_slope_dwn(1,izones) = std(trial_slope_dwn(:,izones));
end

% find the zone with slowest slope
[min_slope_dwn, min_zone_dwn] = min(avg_slope_dwn);

% find the zone with highest slope variability
for izones = 1:zones
    std_slope_dwn(1,izones) = std(trial_slope_dwn(:,izones));
end
[max_std_slope_dwn, max_std_zone_dwn] = max(std_slope_dwn);

test.results.avg_slope_dwn = avg_slope_dwn;
test.results.std_slope_dwn = std_slope_dwn;
test.results.zone_min_slope_dwn = [min_slope_dwn, min_zone_dwn];
test.results.zone_max_std_slope_dwn = [max_std_slope_dwn, max_std_zone_dwn];

%%% estimation at zone level on averaged trials %%%
for izones = 1:zones
    switch izones
        case 1
            for istim = 1:stim_num
                z1_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
            end
            avg_rampdwn_temp_feedb(izones,:) = mean(z1_rampdwn_temp_feedb);
        case 2
            for istim = 1:stim_num
                z2_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
            end
            avg_rampdwn_temp_feedb(izones,:) = mean(z2_rampdwn_temp_feedb);
        case 3
            for istim = 1:stim_num
                z3_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
            end
            avg_rampdwn_temp_feedb(izones,:) = mean(z3_rampdwn_temp_feedb);
        case 4
            for istim = 1:stim_num
                z4_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
            end
            avg_rampdwn_temp_feedb(izones,:) = mean(z4_rampdwn_temp_feedb);
        case 5
            for istim = 1:stim_num
                z5_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
            end
            avg_rampdwn_temp_feedb(izones,:) = mean(z5_rampdwn_temp_feedb);
    end
end

% warning if slopes are below tolerance level
ramp_tolerance = 0.02; % 2% arbitrary
for izones = 1:zones
    zone_mdldwn{izones} = fitlm(x_rampdwn, avg_rampdwn_temp_feedb(izones,:));
    zone_slope_dwn(izones) = abs(round(table2array(zone_mdldwn{izones}.Coefficients(2,1))*1000));
    if zone_slope_dwn(1,izones) >= ramp_down*(1-ramp_tolerance)
        mess_rampdwn{izones} = strcat(['ramp down @ zones ',num2str(izones),' is reached: ',num2str(round(avg_slope_dwn(1,izones))),' °C/s']);
        disp(mess_rampdwn{izones})
    else
        mess_rampdwn{izones} = strcat(['WARNING! ramp down @ zone ',num2str(izones),' is too low: ',num2str(round(avg_slope_dwn(1,izones))),' °C/s']);
        disp(mess_rampdwn{izones})
    end
end

test.results.zone_slope_dwn = zone_slope_dwn;

% linebreak in command window
disp(' ')

%% save
% write param in text file
fidLog = fopen(fullfile(savePath,txt_filename),'w');
fprintf(fidLog,'TEST: %s \n\nPackage version: %s \n\nDate and time: %s \n\nUser name: %s \n\nTCS: %s \n\nProbe name: %s \n\n%s \n\nBaseline temperature: %s°C \n\nTarget temperature: %s°C \n\nRamp-up speed: %s°C/s \n\nRamp-down: %s°C/s \n\nNotes: %s \n\n',...
    experiment, ver, timestamp, user_name, TCS_name, probe_name, serial_number, num2str(baseline_temp), num2str(target_temp), num2str(ramp_up), num2str(ramp_down), char(comments));

% write results in text file
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'--------------- \n RESULTS \n baseline pre stim:');
for izones = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pre{izones});
end
fprintf(fidLog,'\n Highest variablility at zone %d \n',zone_pre);

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n baseline post stim:');
for izones = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pst{izones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp up:');
for izones = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampup{izones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n overshoot:');
for izones = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_overshoot{izones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp down:');
for izones = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampdwn{izones});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

% save outcomes of the test
save(fullfile(savePath,mat_filename), 'test')
fclose all;
zip(txt_filename(1:end-4),{txt_filename, mat_filename});
delete(mat_filename, txt_filename)
tcs2.close_serial(serialObj)
end

