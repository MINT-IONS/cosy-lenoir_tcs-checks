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
dlgtitle = 'Stimulation parameters';
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
else
end
if isnan(plateau_time) && ~isnan(duration)
    plateau_time = duration - rise_time;
else
end
if isnan(fall_time)
    fall_time = abs((target_temp-baseline_temp))/(ramp_down/1000);
end
if isnan(duration)
    duration = rise_time + plateau_time;
else
end
tcs = info(10);
probe = strcat(info(11),'-',info(12));
comments = info(13);

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


% set stimulation parameters using stimulation_profile
tcs2.enable_temperature_profil(11111)
pause(0.1)
areas = 11111;
num_seg = 5;
% build the stimulation profil with parameters + add pre-stimulus at baseline temeprature during 100 ms and post-stimulus at baseline temperature during 100 ms 
pre_stim_dur = 10;
pst_stim_dur = 10;
pre_stim_temp = baseline_temp;
seg_duration = [pre_stim_dur rise_time/10 plateau_time/10 fall_time/10 pst_stim_dur];
seg_end_temp = [pre_stim_temp*10 target_temp*10 target_temp*10 baseline_temp*10 baseline_temp*10];
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp)

% enable temperature feedback at 100 Hz
tcs2.enable_temperature_feedback(100)
pause(0.1)

%%
% send stimulus
% loop of 10 stimulations
for stim_number = 1:10
    tcs2.stimulate
    pause(1.5)

    % read temperature_feedback
    temporary = tcs2.read_serial;

    % prepare for storing of temperature data for 5 zones and successive stimulation
    temperature_feedback = cell(stim_number,5);

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
        temperature_feedback{stim_number,zones} = temp_feed(zones:5:end);
    end
end
%% plot
F1 = figure('color','w','Position',[0,0,1000,900]);
color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
xvalues = (1:length(temperature_feedback{1}))*10;

% plot theoretical stimulation profil (adding of 10 ms to account for
% feedback/stimulation delay of the TCS2)
x_val = [10 (pre_stim_dur*10) (pre_stim_dur*10+rise_time) (pre_stim_dur*10+rise_time+plateau_time)...
    (pre_stim_dur*10+rise_time+plateau_time+fall_time) (pre_stim_dur*10+rise_time+plateau_time+fall_time+pst_stim_dur*10)];
y_val = [baseline_temp baseline_temp target_temp target_temp baseline_temp baseline_temp];

plot(x_val,y_val,'--m','LineWidth',1.5)

hold on
for zones = 1:5
   plot(xvalues,temperature_feedback{stim_number,zones},'Color',color_plot{zones},'LineWidth',1.5)
   hold on
end

% plotting layout
set(gca,'FontSize',12)
set(gca,'YTick',(baseline_temp:1:target_temp+3))
set(gca,'TickDir','out')
title(['temperature curve for ', 'stimulation at ',num2str(target_temp),'°C'],'FontSize',15);
L = legend('theoretical','zone 1','zone 2','zone 3','zone 4','zone 5');
set(L,'Box','off')
xlabel('time (ms)')
ylabel('temperature (°C)')
ax = gca;
ax.Box = 'off';

%% basic stats
% pre-stimulus consistency
clc
for zones = 1:5
    temp_base_pre{1,zones} = temperature_feedback{1,zones}(1:10);
    sd_base_pre{1,zones} = std(temp_base_pre{1,zones});
    if sd_base_pre{1,zones} == 0 % std should be null because set to baseline temperature for a while already
        disp(strcat(['zone ',num2str(zones),' baseline pre stimulus is steady']))
    else
        disp(strcat(['zone ',num2str(zones),' baseline pre stimulus is not constant!']))
    end
end

% line beak in command window
disp(' ')

% post-stimulus consistency
for zones = 1:5
    temp_base_pst{1,zones} = temperature_feedback{1,zones}(end-9:end);
    sd_base_pst{1,zones} = std(temp_base_pst{1,zones});
    if sd_base_pst{1,zones} <= 0.5 % 0.5°C precision of the instrument
        disp(strcat(['zone ',num2str(zones),' baseline post stimulus is steady']))
    else
        disp(strcat(['zone ',num2str(zones),' baseline post stimulus is not constant!']))
    end
end

% line beak in command window
disp(' ')

%% Ramp_up speed for each zone
% By default 2% of tolerance below the desired ramp up speed is allowed,
% this can be changed using the error parameter below
error = 0.02;

x_rampup = xvalues(1:rise_time/10+1);
for zones = 1:5
    rampup{1,zones} = temperature_feedback{1,zones}(10:(pre_stim_dur+rise_time/10));
    mdlup{zones} = fitlm(x_rampup, rampup{1,zones});
    slope_up(zones) = round(table2array(mdlup{zones}.Coefficients(2,1))*1000);
    if table2array(mdlup{zones}.Coefficients(2,1)) >= ramp_up/1000*(1-error)
        disp(strcat(['ramp up @ zones ',num2str(zones),' is reached: ',num2str(round(table2array(mdlup{zones}.Coefficients(2,1))*1000)),' °C/s']))
    else
        disp(strcat(['WARNING! ramp up @ zone ',num2str(zones),' is too low: ',num2str(round(table2array(mdlup{zones}.Coefficients(2,1))*1000)),' °C/s']))
    end
end

%% plot linear regression for each zone

% prepare theoretical values pre stim + ramp up
x_valup = [10 (pre_stim_dur*10) (pre_stim_dur*10+rise_time)];
y_valup = [baseline_temp baseline_temp target_temp];

% plot linear regression for rampups
F2 = figure('color','w','Position',[0,0,1000,900]);
for zones = 1:5
    subplot(1,5,zones)
    % plot the estimated data
    plot(x_rampup+pre_stim_dur*10,mdlup{1,zones}.Fitted,'k','LineWidth',3)
    hold on
   % plot the actual data
    plot(xvalues(1:pre_stim_dur+rise_time/10),temperature_feedback{stim_number,zones}(1:(pre_stim_dur+rise_time/10)),'Color',color_plot{zones},'LineWidth',2)
    hold on
    % plot the theoretical values
    plot(x_valup,y_valup,'--m','LineWidth',1.5)
    title(strcat('zone-',num2str(zones)),'Color',color_plot{zones})
    if zones == 1
        xlabel('time (ms)')
        ylabel('temperature (°C)')
    else
        xlabel('time (ms)')
    end
end
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 (pre_stim_dur*10+rise_time+10)],'ylim',[baseline_temp-2 target_temp+5]);
legend('estimated','measurement','theoretical','Location','best','box','off')
sgtitle('ramp up','FontWeight','Bold')

%% overshoot
for zones = 1:5
    overshoot(1,zones) = temperature_feedback{1,zones}(pre_stim_dur+1+rise_time/10);
end

%%  target temperature
for zones = 1:5
    for bins = 1:(plateau_time/10)
        temps(zones,bins) = temperature_feedback{zones}(pre_stim_dur+bins+rise_time/10);
    end
end

for zones = 1:5
    for bins = 1:(plateau_time/10)
    sd_temps(zones,bins) = std(temps(zones,1:bins));
    avg_temps(zones,bins) = mean(temps(zones,1:bins));
    end
end

% std in reverse time during plateau
bins = 1:(plateau_time/10);
rev_bins = sort(bins,'descend');
for zones = 1:5
    for bins = 1:(plateau_time/10)
    rev_sd_temps(zones,bins) = std(temps(zones,rev_bins(1:bins)));
    rev_avg_temps(zones,bins) = mean(temps(zones,rev_bins(1:bins)));
    end
end

% reverse plateau temperatures
for zones = 1:5
    for bins = 1:(plateau_time/10)
        rev_temps(zones,bins) = temps(zones,rev_bins(bins));
    end
end

% so we can estimate during how % of the plateau is the probe at striclty at target temperature
find(rev_temps(1,:)==target_temp)

% and the duration when it is considered to be at target temperature


%% Ramp_down speed for each zone
% By default 2% of tolerance below the desired ramp down speed is allowed,
% this can be changed using the error parameter below
error = 0.02;
x_rampdwn = xvalues(1:fall_time/10+1);

% line beak in command window
disp(' ')

for zones = 1:5
    rampdwn{1,zones} = temperature_feedback{1,zones}((pre_stim_dur+rise_time/10+plateau_time/10):(pre_stim_dur+rise_time/10+plateau_time/10+fall_time/10));
    mdldwn{zones} = fitlm(x_rampdwn, rampdwn{1,zones});
    slope_dwn(zones) = abs(round(table2array(mdldwn{zones}.Coefficients(2,1))*1000));
    if abs(table2array(mdldwn{zones}.Coefficients(2,1))) - ramp_down/1000 < (1-error) 
        disp(strcat(['ramp down @ zones ',num2str(zones),' is reached: ',num2str(round(table2array(mdldwn{zones}.Coefficients(2,1))*1000)),' °C/s']))
    else
        disp(strcat(['WARNING! ramp down @ zone ',num2str(zones),' is too low: ',num2str(round(table2array(mdldwn{zones}.Coefficients(2,1))*1000)),' °C/s']))
    end
end

%% plot linear regression for rampdowns
% prepare theoretical values pre stim + ramp up
x_valdwn = [1 fall_time];
y_valdwn = [target_temp baseline_temp];

F3 = figure('color','w','Position',[0,0,1000,900]);
for zones = 1:5
    subplot(1,5,zones)
    % plot the estimated data
    plot(x_rampdwn,mdldwn{1,zones}.Fitted,'k','LineWidth',3)
    hold on
    % plot actual data
    plot(x_rampdwn,rampdwn{1,zones},'Color',color_plot{zones},'LineWidth',2)
     hold on
    % plot the theoretical values
    plot(x_valdwn,y_valdwn,'--m','LineWidth',1.5)
    title(strcat('zone-',num2str(zones)),'Color',color_plot{zones})
    if zones == 1
        xlabel('time (ms)')
        ylabel('temperature (°C)')
    else
        xlabel('time (ms)')
    end
end
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 fall_time+10],'ylim',[baseline_temp-2 target_temp+5]);
legend('estimated','measurement','theoretical','Location','best','box','off')
sgtitle('ramp down','FontWeight','Bold')





%% visualization target temps during plateau
figure
subplot(1,2,1)
for zones = 1:5
plot(sd_temps(zones,:))
hold on
end
title('sd')
subplot(1,2,2)
for zones = 1:5
plot(avg_temps(zones,:))
hold on
end
title('avg')

figure
subplot(1,3,1)
for zones = 1:5
plot(rev_sd_temps(zones,:))
hold on
end
title('rev sd')
subplot(1,3,2)
for zones = 1:5
plot(rev_avg_temps(zones,:))
hold on
end
title('rev avg')
subplot(1,3,3)
for zones = 1:5
plot(rev_temps(zones,:))
hold on
end
title('rev temps')
