% tcs2.TCS_test-zones.m  performs the quick routine check of the device.
% Results are saved in a structure in a .mat file and a summary of parameters and results are saved in a .txt file.
% Both files are then stored in an archive .zip file in the folder of your choice. 
% 
% This routine works with/is part of the package "+tcs2" version 3.0.
% 
% Material needed:
%         1 experiment laptop (Matlab 2014a or later up to 2023b)
%         1 TCS2 + probe
%         1 gel pad?
% 
% This routine works for basic stimulation profile typically starting from baseline temperature,
% then reaching a target temperature and then going back to baseline (5 segments in terms of stimulation profile).
% More complex profil (e.g. sinusoidal stimulation) are not included here.
% 
% First: fill in the GUI with stimulation parameters 
% Second: follow instructions and deliver the stimulations onto the skin/gel pad, move the probe at each beep!
% Third: some basic statistics are provided to assess if the thermode delivered properly the requested heat stimulation. 
% Fourth: send the output files to MINT!
% 
% TCS and probe names are A, B, C, D, or E.
% 
% 
% Cédric Lenoir, MINT, IoNS, UCLouvain, January 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TCS_test_zones

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
    definput = {'', '', 'T03', 'none', '30', '60', '', '', '', '100', '200', '100'};
elseif strcmp(probe_type, '109')
    ramp_limit = 75;
    definput = {'', '', 'T08', 'none', '30', '57', '560', '75', '75', '', '', ''};
    tcs2.write_serail('Of3') % set MRI filter to "high"
elseif strcmp(probe_type, '111')
    definput = {'', '', 'T11', 'none', '30', '57', '560', '75', '75', '', '', ''};
    ramp_limit = 75;
    tcs2.write_serail('Of3') % set MRI filter to "high"
end

% get +tcs2 package version
ver = tcs2.get_version;

% check battery level and confirm
clc
tcs2.get_battery(1)
resp = input('BATTERY OK ? [y/n] ','s');
if strcmp(resp,'n')
    return
else
end


%%% GUI for parameters
prompt = {'\fontsize{12} User Name :','\fontsize{12} Which TCS (name) :',...
    '\fontsize{12} Which probe (name) :','\fontsize{12} Enter comments :',...
    '\fontsize{12} Neutral temperature (°C) :','\fontsize{12} Target temperature (°C) :',... 
    '\fontsize{12} Duration (rise time + plateau in ms) : ',...
    '\fontsize{12} Speed ramp-up (°C/s) : ', '\fontsize{12}  Speed ramp-down (°C/s) : ',...
    '\fontsize{12} For profil segment : Rise time (to target temperature in ms) : ',...
    '\fontsize{12} For profil segment : Plateau (ms) : ',...
    '\fontsize{12} For profil segment : Down time (to neutral temperature in ms) : '};
dlgtitle = 'Heat stimulation parameters';
opts.Interpreter = 'tex';
dims = repmat([1 80],12,1);
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


%%% Additional parameters
% number of stimuli
stim_number = 10;
% active zones of the thermode
zones = 5;
% local function roundn for round to be compatible with all Matlab versions
roundn = @(x,n) round(x.*10.^n)./10.^n;

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
if isnan(plateau_time) && ~isnan(duration)
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
pst_stim_dur = 100;
pre_stim_temp = baseline_temp;
seg_duration = [pre_stim_dur rise_time plateau_time down_time pst_stim_dur];
seg_end_temp = [pre_stim_temp target_temp target_temp baseline_temp baseline_temp];


%%% structure for parameters and results
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
test.param.fall_time = down_time;


%%% create paths to save outcomes in .mat and .txt files
clockVal = clock; % Current date and time as date vector. [year month day hour minute seconds]
timestamp = sprintf('%d-%d-%d-%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6));
experiment = 'test_TCS2';
% make unique texte and mat filenames
txt_filename = strcat(['TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.txt']);
mat_filename = strcat(['TCS2_',sprintf('%s', TCS_name),'_probe_',sprintf('%s', probe_name), '_', sprintf('%s', timestamp),'.mat']);
% results files will be save in the folder of your choice
current_folder = pwd;
chosen_dir = uigetdir(current_folder,'Select folder to save test results');
savePath = chosen_dir;


%%% Initialization of the TCS and stimulation parameters
% set all active areas
areas = 11111;
tcs2.set_active_areas(areas)
pause(0.001)

% set neutral baseline temperature
tcs2.set_neutral_temperature(baseline_temp);
pause(0.001)

% set max temperature to 70 C°
tcs2.set_max_temperature(70); % hidden command to allow stimulation up to 70 C°C !! Not available for all firwmare version.
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


%%% loop to send stimuli

% prepare for storing of temperature data for 5 zones and successive 10 stimulations
temperature_feedback = cell(stim_number,zones);

for istim = 1:stim_number
    clc
    if istim == 1
    disp('PUT the probe on the gel pad.')
    disp('PRESS ANY KEY TO START STIMULATION.')
    pause()
    else
        disp('Do not move... Attention ! / Be ready !')
    end
    pause(1.5)
    tcs2.stimulate
    disp(strcat(['stimulation #',num2str(istim),' /',num2str(stim_number),' sent'])) 
    pause(1.5)
    if istim < 10
        disp('MOVE the probe for next stimulus')
    elseif istim > 9
        disp('Stimulations done! Results will appear...')
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
    for izone = 1:zones
        temperature_feedback{istim,izone} = temp_feed(izone:5:end);
    end
    clear temporary temporary_index temp_feed 
end

test.results.feedback = temperature_feedback;


%%% Checks
% pre-stimulus consistency
clc
disp('---------- RESULTS : -------------------')
disp(' ')
for istim = 1:stim_number
    for izone = 1:zones
        temp_base_pre{istim,izone} = temperature_feedback{istim,izone}(1:10);
        sd_base_pre(istim,izone) = std(temp_base_pre{istim,izone});
        mean_base_pre(istim,izone) = mean(temp_base_pre{istim,izone});
    end
end
for izone = 1:zones
    avg_trial_base_pre(1,izone) = mean(mean_base_pre(:,izone));
    avg_sd_base_pre(1,izone) = mean(sd_base_pre(:,izone));
end
avg_trial_base_pre = roundn(avg_trial_base_pre,1);
avg_sd_base_pre = roundn(avg_sd_base_pre,3);

% warning per zone
for izone = 1:zones
    if avg_sd_base_pre(1,izone) <= 0.1  % 0.1°C relative accuracy of the TCS
        mess_baseline_pre{izone} = strcat(['Pre-stimulus neutral temperature @ zone ',num2str(izone), ' is steady']);
        disp(mess_baseline_pre{izone});
    else
         mess_baseline_pre{izone} = strcat(['WARNING! pre-stimulus neutral temperature @ zone ',num2str(izone),' is not steady!']);
        disp(mess_baseline_pre{izone});
    end
end

% find the zone with highest variability
[avg_sd_zone_pre, zone_pre] = max(avg_sd_base_pre);
test.results.avg_sd_base_pre = avg_sd_base_pre;
test.results.mean_base_pre = avg_trial_base_pre;
test.results.zone_pre_variability = [avg_sd_zone_pre, zone_pre];

% linebreak in command window
disp(' ')

% post-stimulus consistency
for istim = 1:stim_number
    for izone = 1:zones
        temp_base_pst{istim,izone} = temperature_feedback{istim,izone}(end-9:end);
        sd_base_pst(istim,izone) = std(temp_base_pst{istim,izone});
        mean_base_pst(istim,izone) = mean(temp_base_pst{istim,izone});
    end
end
for izone = 1:zones
    avg_trial_base_pst(1,izone) = mean(mean_base_pst(:,izone));
    avg_sd_base_pst(1,izone) = mean(sd_base_pst(:,izone));
end
avg_trial_base_pst = roundn(avg_trial_base_pst,1);
avg_sd_base_pst = roundn(avg_sd_base_pst,3);
% warning per zone
for izone = 1:zones
    if avg_sd_base_pst(1,izone) <= 0.1 % 0.1°C relative accuracy of the TCS
        mess_baseline_pst{izone} = strcat(['Post-stimulus neutral temperature @ zone ',num2str(izone),' is steady']);
        disp(mess_baseline_pst{izone})
    else
        mess_baseline_pst{izone} = strcat(['WARNING! Post-stimulus neutral temperature @ zone ',num2str(izone),' is not steady!']);
        disp(mess_baseline_pst{izone})
    end
end

% find the zone with highest variability
[avg_sd_zone_pst, zone_pst] = max(avg_sd_base_pst);
test.results.avg_sd_base_pst = avg_sd_base_pst;
test.results.mean_base_pst = avg_trial_base_pst;
test.results.zone_pst_variability = [avg_sd_zone_pst, zone_pst];

% linebreak in command window
disp(' ')


%%% Ramp_up speed for each stim and zone
% x values for plotting and linear regression
xvalues = (1:length(temperature_feedback{stim_number,zones}))*10;
x_rampup = xvalues(1:rise_time/10+1);

% variability at trial level
for izone = 1:zones
    for istim = 1:stim_number
        rampup{istim,izone} = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
        mdlup{istim,izone} = fitlm(x_rampup, rampup{istim,izone});
        trial_slope_up(istim,izone) = roundn(table2array(mdlup{istim,izone}.Coefficients(2,1))*1000,1);
    end
end

for izone = 1:zones
    avg_slope_up(1,izone) = mean(trial_slope_up(:,izone));
    std_slope_up(1,izone) = std(trial_slope_up(:,izone));
end
avg_slope_up = roundn(avg_slope_up,1);
std_slope_up = roundn(std_slope_up,2);

% find the zone with slowest slope
[min_slope_up, min_zone_up] = min(avg_slope_up);

% find the zone with highest slope variability
[max_std_slope_up, max_std_zone_up] = max(std_slope_up);

test.results.avg_slope_up = avg_slope_up;
test.results.std_slope_up = std_slope_up;
test.results.zone_min_slope_up = [min_slope_up, min_zone_up];
test.results.zone_max_std_slope_up = [max_std_slope_up, max_std_zone_up];

% estimation at zone level on averaged trials
for izone = 1:zones
    switch izone
        case 1
            for istim = 1:istim
                z1_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
            end
            avg_rampup_temp_feedb(izone,:) = mean(z1_rampup_temp_feedb);
        case 2
            for istim = 1:istim
                z2_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
            end
            avg_rampup_temp_feedb(izone,:) = mean(z2_rampup_temp_feedb);
        case 3
            for istim = 1:istim
                z3_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
            end
            avg_rampup_temp_feedb(izone,:) = mean(z3_rampup_temp_feedb);
        case 4
            for istim = 1:istim
                z4_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
            end
            avg_rampup_temp_feedb(izone,:) = mean(z4_rampup_temp_feedb);
        case 5
            for istim = 1:istim
                z5_rampup_temp_feedb(istim,:) = temperature_feedback{istim,izone}(10+1:(pre_stim_dur/10+rise_time/10)+1);
            end
            avg_rampup_temp_feedb(izone,:) = mean(z5_rampup_temp_feedb);
    end
end

% warning if slopes are below tolerance level
ramp_tolerance = 0.02; % 2% arbitrary

for izone = 1:zones
    zone_mdlup{izone} = fitlm(x_rampup, avg_rampup_temp_feedb(izone,:));
    zone_slope_up(izone) = roundn(table2array(zone_mdlup{izone}.Coefficients(2,1))*1000,1);
    if zone_slope_up(1,izone) >= ramp_up*(1-ramp_tolerance)
        mess_rampup{izone} = strcat(['Ramp up @ zone ',num2str(izone),' is reached: ',num2str(roundn(avg_slope_up(1,izone),0)),' °C/s']);
        disp(mess_rampup{izone})
    else
        mess_rampup{izone} = strcat(['WARNING! ramp up @ zone ',num2str(izone),' is low: ',num2str(roundn(avg_slope_up(1,izone),0)),' °C/s']);
        disp(mess_rampup{izone})
    end
end

test.results.zone_slope_up = zone_slope_up;

% linebreak in command window
disp(' ')


%%% overshoot
% extract temperature at 4 samples around expected max

for izone = 1:zones
    switch izone
        case 1
            for istim = 1:stim_number
                z1_overshoot_range(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+1+rise_time/10)-1:(pre_stim_dur/10+1+rise_time/10)+2);
            end
            avg_overshoot_range(izone,:) = mean(z1_overshoot_range);
        case 2
            for istim = 1:stim_number
                z2_overshoot_range(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+1+rise_time/10)-1:(pre_stim_dur/10+1+rise_time/10)+2);
            end
            avg_overshoot_range(izone,:) = mean(z2_overshoot_range);
        case 3
            for istim = 1:stim_number
                z3_overshoot_range(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+1+rise_time/10)-1:(pre_stim_dur/10+1+rise_time/10)+2);
            end
            avg_overshoot_range(izone,:) = mean(z3_overshoot_range);
        case 4
            for istim = 1:stim_number
                z4_overshoot_range(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+1+rise_time/10)-1:(pre_stim_dur/10+1+rise_time/10)+2);
            end
            avg_overshoot_range(izone,:) = mean(z4_overshoot_range);
        case 5
            for istim = 1:stim_number
                z5_overshoot_range(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+1+rise_time/10)-1:(pre_stim_dur/10+1+rise_time/10)+2);
            end
            avg_overshoot_range(izone,:) = mean(z5_overshoot_range);
    end
end

% find max overshoot in range
for izone = 1:zones
    [overshoot(izone,1), idx_overshoot(izone,:)] = max(avg_overshoot_range(izone,:));
end
overshoot = roundn(overshoot,1);

% warning
for izone = 1:zones
    if overshoot(izone,1) - target_temp < 0
        mess_overshoot{izone} = strcat(['WARNING! max peak temperature @ zone ',num2str(izone)',' is ',num2str(overshoot(izone,1) - target_temp),'°C below target temperature']);
        disp(mess_overshoot{izone});
    else
        mess_overshoot{izone} = strcat(['Overshoot @ zone ',num2str(izone),' acceptable, ',num2str(overshoot(izone,1)),'°C']);
        disp(mess_overshoot{izone});
    end
end

test.results.avg_overshoot_range = avg_overshoot_range;
test.results.overshoot = overshoot;
test.results.idx_overshoot = idx_overshoot;

% linebreak in command window
disp(' ')


%%%  plateau at target temperature
for istim = 1:stim_number
    for izone = 1:zones
        for bins = 1:(plateau_time/10)-1
            plateau_temp{istim,izone}(bins) = temperature_feedback{istim,izone}(pre_stim_dur/10+bins+1+rise_time/10); % excluding overshoot
            sd_plateau_temp(istim,izone) = std(plateau_temp{istim,izone});
            avg_plateau_temp(istim,izone) = mean(plateau_temp{istim,izone});
        end
    end
end
for izone = 1:zones
    avg_sd_plateau_temp(1,izone) = roundn(mean(sd_plateau_temp(:,izone)),2);
    avg_stim_plateau_temp(1,izone) = roundn(mean(avg_plateau_temp(:,izone)),1);
end

% warning per zone
for izone = 1:zones
    if avg_sd_plateau_temp(1,izone) <= 0.2 % 0.2°C given the recovery after overshoot (0.1°C relative accuracy of the TCS)
        mess_plateau_temp{izone} = strcat(['Plateau temperature @ zone ',num2str(izone),' is steady']);
        disp(mess_plateau_temp{izone})
    else
        mess_plateau_temp{izone} = strcat(['WARNING! plateau temperature @ zone ',num2str(izone),' is not steady!']);
        disp(mess_plateau_temp{izone})
    end
end
disp(' ')
for izone = 1:zones
    if avg_stim_plateau_temp(1,izone) >= target_temp - 0.2 % 0.2°C (0.1°C relative accuracy of the TCS)
        mess_plateau_temp{izone} = strcat(['Plateau temperature @ zone ',num2str(izone),' is reached : ',num2str(avg_stim_plateau_temp(1,izone)) ,'°C']);
        disp(mess_plateau_temp{izone})
    else
        mess_plateau_temp{izone} = strcat(['WARNING! plateau temperature @ zone ',num2str(izone),' is not reached : ',num2str(avg_stim_plateau_temp(1,izone)),'°C']);
        disp(mess_plateau_temp{izone})
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


%%% Ramp_down speed for each zone
% x values for plotting and linear regression
x_rampdwn = xvalues(1:down_time/10+1);

% variability at trial level
for izone = 1:zones
    for istim = 1:stim_number
        rampdwn{istim,izone} = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
        mdldwn{istim,izone} = fitlm(x_rampdwn, rampdwn{istim,izone});
        trial_slope_dwn(istim,izone) = abs(roundn(table2array(mdldwn{istim,izone}.Coefficients(2,1))*1000,1));
    end
end
for izone = 1:zones
    avg_slope_dwn(1,izone) = mean(trial_slope_dwn(:,izone));
    std_slope_dwn(1,izone) = std(trial_slope_dwn(:,izone));
end

% find the zone with slowest slope
[min_slope_dwn, min_zone_dwn] = min(avg_slope_dwn);

% find the zone with highest slope variability
for izone = 1:zones
    std_slope_dwn(1,izone) = std(trial_slope_dwn(:,izone));
end
[max_std_slope_dwn, max_std_zone_dwn] = max(std_slope_dwn);

test.results.avg_slope_dwn = avg_slope_dwn;
test.results.std_slope_dwn = std_slope_dwn;
test.results.zone_min_slope_dwn = [min_slope_dwn, min_zone_dwn];
test.results.zone_max_std_slope_dwn = [max_std_slope_dwn, max_std_zone_dwn];

% estimation at zone level on averaged trials
for izone = 1:zones
    switch izone
        case 1
            for istim = 1:istim
                z1_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
            end
            avg_rampdwn_temp_feedb(izone,:) = mean(z1_rampdwn_temp_feedb);
        case 2
            for istim = 1:istim
                z2_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
            end
            avg_rampdwn_temp_feedb(izone,:) = mean(z2_rampdwn_temp_feedb);
        case 3
            for istim = 1:istim
                z3_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
            end
            avg_rampdwn_temp_feedb(izone,:) = mean(z3_rampdwn_temp_feedb);
        case 4
            for istim = 1:istim
                z4_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
            end
            avg_rampdwn_temp_feedb(izone,:) = mean(z4_rampdwn_temp_feedb);
        case 5
            for istim = 1:istim
                z5_rampdwn_temp_feedb(istim,:) = temperature_feedback{istim,izone}((pre_stim_dur/10+rise_time/10+plateau_time/10+1):(pre_stim_dur/10+rise_time/10+plateau_time/10+down_time/10+1));
            end
            avg_rampdwn_temp_feedb(izone,:) = mean(z5_rampdwn_temp_feedb);
    end
end

% warning if slopes are below tolerance level
ramp_tolerance = 0.02; % 2% arbitrary
for izone = 1:zones
    zone_mdldwn{izone} = fitlm(x_rampdwn, avg_rampdwn_temp_feedb(izone,:));
    zone_slope_dwn(izone) = abs(roundn(table2array(zone_mdldwn{izone}.Coefficients(2,1))*1000,1));
    if zone_slope_dwn(1,izone) >= ramp_down*(1-ramp_tolerance)
        mess_rampdwn{izone} = strcat(['Ramp down @ zone ',num2str(izone),' is reached: ',num2str(roundn(avg_slope_dwn(1,izone),0)),' °C/s']);
        disp(mess_rampdwn{izone})
    else
        mess_rampdwn{izone} = strcat(['WARNING! ramp down @ zone ',num2str(izone),' is low: ',num2str(roundn(avg_slope_dwn(1,izone),0)),' °C/s']);
        disp(mess_rampdwn{izone})
    end
end

test.results.zone_slope_dwn = zone_slope_dwn;

% linebreak in command window
disp(' ')


%%% write param in text file
fidLog = fopen(fullfile(savePath,txt_filename),'w');
fprintf(fidLog,'TEST: %s \n\nPackage version: %s \n\nDate and time: %s \n\nUser name: %s \n\nTCS: %s \n\nProbe name: %s \n\n%s \n\nBaseline temperature: %s°C \n\nTarget temperature: %s°C \n\nRamp-up speed: %s°C/s \n\nRamp-down: %s°C/s \n\nNotes: %s \n\n',...
    experiment, ver, timestamp, user_name, TCS_name, probe_name, serial_number, num2str(baseline_temp), num2str(target_temp), num2str(ramp_up), num2str(ramp_down), char(comments));

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'--------------- \n RESULTS \n baseline pre stim:');
for izone = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pre{izone});
end
fprintf(fidLog,'\n Highest variablility at zone %d \n',zone_pre);

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n baseline post stim:');
for izone = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_baseline_pst{izone});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp up:');
for izone = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampup{izone});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n overshoot:');
for izone = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_overshoot{izone});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');

fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n ramp down:');
for izone = 1:zones
    fidLog = fopen(fullfile(savePath,txt_filename),'a+');
    fprintf(fidLog,'\n %s',mess_rampdwn{izone});
end
fidLog = fopen(fullfile(savePath,txt_filename),'a+');
fprintf(fidLog,'\n');


%%% save outcomes of the test
save(fullfile(savePath,mat_filename), 'test')
fclose all;
cd(savePath)
zip(txt_filename(1:end-4),{txt_filename, mat_filename});
delete(mat_filename, txt_filename)
cd(current_folder)
tcs2.close_serial(serialObj)

disp('Data saved in zip file, PLEASE SEND IT TO MINT :-)')
end