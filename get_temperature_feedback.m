% temperature_feedback

% preallocation for speed purposes
temperature_feedback = cell(1,5); % Temperature data will be stored here.
% disp('Extracting temperature feedback...')
% tcs2.current_serial(com)
pause(1)
temporary = tcs2.read_serial ;              % Extract raw data from TCS
pause(1)
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
% color_plot = {'k','b','r','g','m'};
% xvalues = (1:length(temperature_feedback{1}))*10;
% hold on
% for c = 1:5
%    plot(xvalues,temperature_feedback{stimulation_number,c},color_plot{c})
% end
% hold off
% title(['temperature curve for ',condition, 'stimulation at',num2str(STIM_TEMPERATURE),'°C']);
% legend('1','2','3','4','5');
% xlabel('time (ms)');
% ylabel('temperature (Â°C)');
% Box = 'off';
% set(gcf,'Color','w')