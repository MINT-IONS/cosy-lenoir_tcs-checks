global COM TCS2_COMS
TCS2_COMS = 'COM9';
% Init TCS2
disp('Initializing TCS-II...')

% parameters for stimulation profiles
areas = 11000; % zones 1 and 2
num_seg = 3; % ramp-up + plateau + ramp down
seg_duration = [10 10 80]; % in tens of ms
% set temperatures depending on right and left temperature obtained from the calibration task
seg_end_temp(:,1) = [62*10 62*10 32*10]; % in 1/10°C
seg_end_temp(:,2) = [62.5*10 62.5*10 320];

TCS2_NUMBER = [1 2]; % LEFT -> 1; RIGHT -> 2 (% second COM port encoded in the variable " TCS2_COMS" in the script hypnoanalgesia_init)

% assign corresponding triggers; default duration 10 ms
TCS2_TRIGGER_OUT = [1 125]; % LEFT -> 1; RIGHT -> 125
TCS2_TRIGGER_OUT_DUR = [50 50];


if isempty(COM)
    COM = tcs2.init_serial(char(TCS2_COMS));
else
    COM = tcs2.init_serial(char(TCS2_COMS));
end
tcs2.current_serial(COM)
tcs2.init_tcs;
% check battery level and confirm
tcs2.write_serial('B')
pause()
disp('BATTERY OK ? press ENTER')
% set neutral baseline temperature
tcs2.set_neutral_temperature(32);
pause(0.1)
% enable trigger-in
tcs2.set_trigger_in('on')
pause(0.1)
% set max temperature to 70°
tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 °C !! Not available for all firwmare version.
tcs2.write_serial('Om700');
pause(0.1)
% enable temperature profile
tcs2.enable_temperature_profil(11000)
pause(0.1)
% disable temperature feedback "mute mode"
tcs2.enable_temperature_feedback(100)
% set trigger value
tcs2.set_trigger_out(TCS2_TRIGGER_OUT(1),TCS2_TRIGGER_OUT_DUR(1));
% set profile
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp(:,1));

%%
NI = NIdaq.initialize_NI;

%%
%% Prepare block 1 triggers for NI
% sequences of pairs of stimuli (L-R; R-L; L-R; R-L)
pair_hands = [1; 2; 1; 2];
% pair_hands = [1; 2; 1; 2; 1; 2; 2; 1; 2; 1; 2; 1; 2; 1; 1; 2];

abs_SOA = 0.3;

for trial_time = 1:length(pair_hands)
    % create matrices to send to NI played using TCS_stimulate_training.m
    % foreperiod_duration between 500 and 1000 ms from rectangular distribution
    lowerBound = 0.5;
    upperBound = 1;
    roundn = @(x,n) round(x.*10.^n)./10.^n;
    foreperiod_duration = roundn((lowerBound + (upperBound - lowerBound) * rand),3);
    
    % trigger amplitude (V)
    amplitude = 5;
    
    % duration_bins
    pair_duration = abs_SOA+0.01;
    wait_duration = 1-0.01;
    stim_duration = pair_duration + wait_duration;
    SOA_bins = abs_SOA*NI.Rate;
    
    stim_duration_bins = stim_duration*NI.Rate;
    foreperiod_duration_bins = foreperiod_duration*NI.Rate;
    
    tpx = 1:1:stim_duration_bins;
    tpx = (tpx-1)/NI.Rate;
    tpy = tpx.*0;
    
    % foreperiod
    tpy = [zeros(1,foreperiod_duration_bins) tpy];
    tpx = 1:length(tpy);
    tpx = (tpx-1)/NI.Rate;
    
    % trigger 1 (50 ms)
    tpy_trigger1 = zeros(size(tpy));
    tpy_trigger1(foreperiod_duration_bins:foreperiod_duration_bins+0.05*NI.Rate) = amplitude;
    
    % trigger 2 (50 ms)
    tpy_trigger2 = zeros(size(tpy));
    tpy_trigger2(foreperiod_duration_bins+SOA_bins:foreperiod_duration_bins+0.05*NI.Rate+SOA_bins) = amplitude;
    
    % trigger 3 LED
    tpy_trigger3 = zeros(size(tpy));
    tpy_trigger3(2:end-1) = amplitude;
    
    % fpy
    fpy_temp = zeros(length(tpy),3);
    if pair_hands(trial_time) == 1
        fpy_temp(:,1) = tpy_trigger1; % TCS left
        fpy_temp(:,2) = tpy_trigger2; % TCS right
        fpy_temp(:,3) = tpy_trigger3; % LED
    elseif pair_hands(trial_time) == 2
        fpy_temp(:,1) = tpy_trigger2; % TCS left
        fpy_temp(:,2) = tpy_trigger1; % TCS right
        fpy_temp(:,3) = tpy_trigger3; % LED
    end
    fpy_block1{trial_time,1} = fpy_temp;
end
evnt = 1;
trial = 1;
block = 1;
questdlg('!!!!! NON CROISES - QUELLE MAIN EN PREMIER !!!!!', 'ATTENTION','OK','OK');
fpy = fpy_block1{trial,1};

%%
wait_stim = 1;
instr = 'Ready to stimulate LEFT then RIGHT hands ? [y] ';
resp = input(instr,'s');
while wait_stim
    if strcmp(resp,'y')
        wait_stim = 0;
        %             disp('stimuli are sent, foreperiod with LED ON')
        % stimulate and store results
        data = NIdaq.TCS_stimulate_training(NI,fpy);
    end
end

%% get temperature feedback
% temperature_feedback
temporary = tcs2.read_serial;              % Extract raw data from TCS
pause(1)
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
end
hold on
% plot theoretical stimulation profil
% plot([10 ramp_up_time+10 TCS_DURATION+10],[TCS_neutraltemp TCS_reftemp TCS_reftemp],'--k')

set(gca,'FontSize',12);
set(gca,'TickDir','out')
title(['temperature curve for ', 'stimulation at ',num2str(TCS_reftemp),'°C'],'FontSize',15);
L = legend('1','2','3','4','5');
set(L,'Box','off')
xlabel('time (ms)')
ylabel('temperature (°C)')
ax = gca;
ax.Box = 'off';
set(gcf,'Color','w')
