%% plot stimulus profil

stim_num = 8;
zones = 5;

F1 = figure('color','w','Position',[0,0,1000,900]);
color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
xvalues = (1:length(temperature_feedback{stim_num,zones}))*10;

% plot theoretical stimulation profil (adding of 10 ms to account for
% feedback/stimulation delay of the TCS2)
x_val = [10 (pre_stim_dur*10) (pre_stim_dur*10+rise_time) (pre_stim_dur*10+rise_time+plateau_time)...
    (pre_stim_dur*10+rise_time+plateau_time+fall_time) (pre_stim_dur*10+rise_time+plateau_time+fall_time+pst_stim_dur*10)];
y_val = [baseline_temp baseline_temp target_temp target_temp baseline_temp baseline_temp];

plot(x_val,y_val,'--m','LineWidth',1.5)

hold on
for zones = 1:5
   plot(xvalues,temperature_feedback{stim_num,zones},'Color',color_plot{zones},'LineWidth',1.5)
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

%% plot linear regression for each zone

% prepare theoretical values pre stim + ramp up
% x_valup = [10 (pre_stim_dur*10) (pre_stim_dur*10+rise_time)];
% y_valup = [baseline_temp baseline_temp target_temp];
% 
% % plot linear regression for rampups
% F2 = figure('color','w','Position',[0,0,1000,900]);
% for zones = 1:5
%     subplot(1,5,zones)
%     % plot the estimated data
%     plot(x_rampup+pre_stim_dur*10,mdlup{1,zones}.Fitted,'k','LineWidth',3)
%     hold on
%    % plot the actual data
%     plot(xvalues(1:pre_stim_dur+rise_time/10),temperature_feedback{stim_number,zones}(1:(pre_stim_dur+rise_time/10)),'Color',color_plot{zones},'LineWidth',2)
%     hold on
%     % plot the theoretical values
%     plot(x_valup,y_valup,'--m','LineWidth',1.5)
%     title(strcat('zone-',num2str(zones)),'Color',color_plot{zones})
%     if zones == 1
%         xlabel('time (ms)')
%         ylabel('temperature (°C)')
%     else
%         xlabel('time (ms)')
%     end
% end
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 (pre_stim_dur*10+rise_time+10)],'ylim',[baseline_temp-2 target_temp+5]);
% legend('estimated','measurement','theoretical','Location','best','box','off')
% sgtitle('ramp up','FontWeight','Bold')

%% plot linear regression for rampdowns

% % prepare theoretical values pre stim + ramp up
% x_valdwn = [1 fall_time];
% y_valdwn = [target_temp baseline_temp];
% 
% F3 = figure('color','w','Position',[0,0,1000,900]);
% for zones = 1:5
%     subplot(1,5,zones)
%     % plot the estimated data
%     plot(x_rampdwn,mdldwn{1,zones}.Fitted,'k','LineWidth',3)
%     hold on
%     % plot actual data
%     plot(x_rampdwn,rampdwn{1,zones},'Color',color_plot{zones},'LineWidth',2)
%      hold on
%     % plot the theoretical values
%     plot(x_valdwn,y_valdwn,'--m','LineWidth',1.5)
%     title(strcat('zone-',num2str(zones)),'Color',color_plot{zones})
%     if zones == 1
%         xlabel('time (ms)')
%         ylabel('temperature (°C)')
%     else
%         xlabel('time (ms)')
%     end
% end
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 fall_time+10],'ylim',[baseline_temp-2 target_temp+5]);
% legend('estimated','measurement','theoretical','Location','best','box','off')
% sgtitle('ramp down','FontWeight','Bold')

%% visualization target temps during plateau

% figure
% subplot(1,2,1)
% for zones = 1:5
% plot(sd_temps(zones,:))
% hold on
% end
% title('sd')
% subplot(1,2,2)
% for zones = 1:5
% plot(avg_temps(zones,:))
% hold on
% end
% title('avg')
% 
% figure
% subplot(1,3,1)
% for zones = 1:5
% plot(rev_sd_temps(zones,:))
% hold on
% end
% title('rev sd')
% subplot(1,3,2)
% for zones = 1:5
% plot(rev_avg_temps(zones,:))
% hold on
% end
% title('rev avg')
% subplot(1,3,3)
% for zones = 1:5
% plot(rev_temps(zones,:))
% hold on
% end
% title('rev temps')
