% temperature_feedback

% preallocation for speed purposes
number_of_stimulation = 1; % Change this to your number of stimulations
temp_feed = cell(number_of_stimulation,5); % Temperature data will be stored here.
tcs2.current_serial(com);
pause(1);

% disp('Extracting temperature feedback...')
temporary = tcs2.read_serial ;              % Extract raw data from TCS
temporary_index = strfind(temporary,'+');   % Extract position of temperature data from raw data
temp_feed = zeros(1,length(temporary_index)); % Preallocation for speed purposes

% Extract and store temperature data in a cell array
for a = 1:length(temporary_index)
    temp_feed(a) = str2double(temporary(temporary_index(a)+1:temporary_index(a)+4));
end

% This should match the current stimulation number (probably the loop variable)
stimulation_number = 1;
for b = 1:5
    temp_feed{stimulation_number,b} = temp_feed(b:5:end);
end

% plot
%color_plot = {'k','b','r','g','m'};
%xvalues = (1:length(temp_feed{1}))*10;
%hold on
%for c = 1:5
%    plot(xvalues,temp_feed{stimulation_number,c},color_plot{c})
% end
% hold off
% title(['temperature curve for ',condition, 'stimulation at',num2str(STIM_TEMPERATURE),'°C']);
% legend('1','2','3','4','5');
% xlabel('time (ms)');
% ylabel('temperature (°C)');
% Box = 'off';
% set(gcf,'Color','w')