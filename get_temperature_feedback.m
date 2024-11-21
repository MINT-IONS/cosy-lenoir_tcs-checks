function temperature_feedback = get_temperature_feedback
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

% % plot
% F = figure('Position',[0,0,1000,900]);
% color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
% xvalues = (1:length(temperature_feedback{1}))*10;
% hold on
% for c = 1:5
%     plot(xvalues,temperature_feedback{stimulation_number,c},'Color',color_plot{c},'LineWidth',1.5)
% end
% hold on
% % plot theoretical stimulation profil
% plot([10 100 260],[35 62 62],'--k')
% 
% set(gca,'FontSize',12);
% set(gca,'TickDir','out')
% title(['temperature curve for ', 'stimulation at ',num2str(TCS_reftemp),'°C'],'FontSize',15);
% L = legend('1','2','3','4','5');
% set(L,'Box','off')
% xlabel('time (ms)')
% ylabel('temperature (°C)')
% Box = 'off';
% set(gcf,'Color','w')

end