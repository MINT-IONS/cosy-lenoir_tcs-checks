%% initialize
condition = inputdlg('Probe against skin or in the air ? : ');
STIM_DURATION = 1000; %(ms)
RAMP_UP   = 300;     %(deg/s)
RAMP_DOWN = 30;     %(deg/s)

STIM_TEMPERATURE = 65; % [gauche droite] (°C)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Initializing TCS2..')
COM = tcs2.find_com_port();
COM = tcs2.init_serial(COM);

tcs2.init_tcs;

tcs2.set_neutral_temperature(32);
tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 °C !! Not available for all firwmare version.
tcs2.write_serial('Om700'); % set max temperature to 70°

tcs2.set_stim_duration(STIM_DURATION, RAMP_UP, RAMP_DOWN);
tcs2.set_stim_temperature(STIM_TEMPERATURE);

% feedback
tcs2.enable_temperature_feedback(100);

%% stimulation

tcs2.stimulate

% preallocation for speed purposes
number_of_stimulation = 1; % Change this to your number of stimulations
temperature_feedback = cell(number_of_stimulation,5); % Temperature data will be stored here. 
tcs2.current_serial(COM); 
pause(1);
disp('Extracting temperature feedback...')  % Optional
temporary = tcs2.read_serial ;              % Extract raw data from TCS
temporary_index = strfind(temporary,'+');   % Extract position of temperature data from raw data
temp_feed = zeros(1,length(temporary_index)); % Preallocation for speed purposes
% Extract and store temperature data in a cell array
for a = 1:length(temporary_index)
    temp_feed(a) = str2double(temporary(temporary_index(a)+1:temporary_index(a)+4));
end
stimulation_number = 1;  
    % This should match the current stimulation number (probably the loop variable)           
for b = 1:5
    temperature_feedback{stimulation_number,b} = temp_feed(b:5:end); 
end
% plot
color_plot = {'k','b','r','g','m'};
xvalues = (1:length(temperature_feedback{1}))*10; 
hold on
for c = 1:5
    plot(xvalues,temperature_feedback{stimulation_number,c},color_plot{c})
end
hold off
title(['temperature curve for ',condition, 'stimulation at',num2str(STIM_TEMPERATURE),'°C']);
legend('1','2','3','4','5');
xlabel('time (ms)');
ylabel('temperature (°C)');
Box = 'off';
set(gcf,'Color','w')




