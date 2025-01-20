%% plot stimulus profil and average feedback per zone

% load the data from the test routine TCS_test_zones.m
load('TCS2_D_test_1_12-16-2024-14-24-4.mat','test')
temperature_feedback = test.results.feedback;

stim_num = 10;
zones = 5;

F1 = figure('color','w','Position',[0,0,1000,900]);
color_plot = {[0,0.4470,0.7410],[0.85,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188]};
xvalues = (1:length(temperature_feedback{stim_num,zones}))*10;

% plot theoretical stimulation profil (adding of 10 ms to account for
% feedback/stimulation delay of the TCS2)
% x_val = [10 (10+test.param.pre_stim_dur) (10+test.param.pre_stim_dur+test.param.rise_time) (test.param.pre_stim_dur+test.param.rise_time+test.param.plateau_time)...
%     (test.param.pre_stim_dur+test.param.rise_time+test.param.plateau_time+test.param.fall_time) (test.param.pre_stim_dur+test.param.rise_time+test.param.plateau_time+test.param.fall_time+test.param.pst_stim_dur)];
x_val = cumsum([10 test.param.pre_stim_dur test.param.rise_time test.param.plateau_time test.param.fall_time test.param.pst_stim_dur]);
y_val = [test.param.pre_stim_temp test.param.pre_stim_temp test.param.target_temp test.param.target_temp test.param.pre_stim_temp test.param.pre_stim_temp];

plot(x_val,y_val,'--m','LineWidth',1.5)
hold on

for izones = 1:zones
    switch izones
        case 1
            for istim = 1:stim_num
                z1_temperature_feedback(istim,:) = temperature_feedback{istim,izones};
            end
            avg_temp_feedb(izones,:) = mean(z1_temperature_feedback);
        case 2
            for istim = 1:stim_num
                z2_temperature_feedback(istim,:) = temperature_feedback{istim,izones};
            end
            avg_temp_feedb(izones,:) = mean(z2_temperature_feedback);
        case 3
            for istim = 1:stim_num
                z3_temperature_feedback(istim,:) = temperature_feedback{istim,izones};
            end
            avg_temp_feedb(izones,:) = mean(z3_temperature_feedback);
        case 4
            for istim = 1:stim_num
                z4_temperature_feedback(istim,:) = temperature_feedback{istim,izones};
            end
            avg_temp_feedb(izones,:) = mean(z4_temperature_feedback);
        case 5
            for istim = 1:stim_num
                z5_temperature_feedback(istim,:) = temperature_feedback{istim,izones};
            end
            avg_temp_feedb(izones,:) = mean(z5_temperature_feedback);
    end
end
for izones = 1:zones
switch izones
    case 1
    avg_temp_feedb(izones,:) = z1_temperature_feedback;
    case 2
        avg_temp_feedb(izones,:) = z2_temperature_feedback;
    case 3
        avg_temp_feedb(izones,:) = z3_temperature_feedback;
    case 4
        avg_temp_feedb(izones,:) = z4_temperature_feedback;
    case 5
        avg_temp_feedb(izones,:) = z5_temperature_feedback;
end
end
for izones = 1:zones
    plot(xvalues,avg_temp_feedb(izones,:),'Color',color_plot{izones},'LineWidth',1)
    hold on
end

% plotting layout
set(gca,'FontSize',12)
set(gca,'YTick',(test.param.pre_stim_temp:1:test.param.target_temp+3))
set(gca,'TickDir','out')
title(['average temperature time course ', '(',num2str(test.param.target_temp),'°C)'],'FontSize',15);
L = legend('theoretical','zone 1','zone 2','zone 3','zone 4','zone 5');
set(L,'Box','off')
xlabel('time (ms)')
ylabel('temperature (°C)')
ax = gca;
ax.Box = 'off';

%% plot linear regression for each zone avearged across trials

% prepare theoretical values pre stim + ramp up
x_valup = [10 (test.param.pre_stim_dur) (test.param.pre_stim_dur+test.param.rise_time)];
y_valup = [test.param.pre_stim_temp test.param.pre_stim_temp test.param.target_temp];

% plot linear regression for rampups
F2 = figure('color','w','Position',[0,0,1000,900]);
for izones = 1:zones
    subplot(1,5,izones)
    for stim_num = 1:stim_number
        % plot the estimated data
        pfit= plot(x_rampup+test.param.pre_stim_dur,mdlup{stim_num,izones}.Fitted,'k','LineWidth',1);
        hold on
        % plot the actual data of each trial
        pobs = plot(xvalues(1:(test.param.pre_stim_dur+test.param.rise_time)/10),temperature_feedback{stim_num,izones}(1:(test.param.pre_stim_dur+test.param.rise_time)/10),'Color',color_plot{izones},'LineWidth',2);
        hold on
    end

    % plot the theoretical values
    pth = plot(x_valup,y_valup,'--m','LineWidth',1);
    title(strcat('zone-',num2str(zones)),'Color',color_plot{izones})
    if izones == 1
        xlabel('time (ms)')
        ylabel('temperature (°C)')
    else
        xlabel('time (ms)')
    end
end

set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 (pre_stim_dur*10+rise_time+10)],'ylim',[pre_stim_temp-2 target_temp+5]);
L2 = legend([pfit, pobs, pth], 'estimated','measurement','theoretical','Location','none','Position',[0.9 0.82 0.05 0.05],'box','off');
sgtitle('ramp up','FontWeight','Bold')

%% plot linear regression for rampdowns

% prepare theoretical values pre stim + ramp up
x_valdwn = [1 fall_time];
y_valdwn = [target_temp pre_stim_temp];

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
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',12,'FontWeight','Normal', 'LineWidth', 0.5,'Box','off','xlim',[0 fall_time+10],'ylim',[pre_stim_temp-2 target_temp+5]);
legend('estimated','measurement','theoretical','Location','best','box','off')
sgtitle('ramp down','FontWeight','Bold')

%% visualization target temps during plateau

figure
subplot(1,2,1)
for izones = 1:zones
plot(sd_plateau_temp(:,izones))
hold on
end
title('sd')
subplot(1,2,2)
for izones = 1:zones
plot(avg_temps(izones,:))
hold on
end
title('avg')

figure
subplot(1,3,1)
for izones = 1:zones
plot(rev_sd_temps(izones,:))
hold on
end
title('rev sd')
subplot(1,3,2)
for izones = 1:zones
plot(rev_avg_temps(izones,:))
hold on
end
title('rev avg')
subplot(1,3,3)
for izones = 1:zones
plot(rev_temps(izones,:))
hold on
end
title('rev temps')
