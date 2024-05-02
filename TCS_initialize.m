
%%%%%%%%%%%%%%%%%%%%%%%%
% in initialize
% %TCS com port
% TCS_comport = 'COM5';
% %TCS neutral temp
% TCS_neutraltemp = 35;
% %TCS maximum temp
% TCS_maxtemp = 70;

global com

TCS_DURATION = 250; % ms
TCS_RAMP_UP = 300; % °C/s
TCS_reftemp = 62;
TCS_neutraltemp = 35;
TCS_delta_temp = TCS_reftemp-TCS_neutraltemp;
ramp_up_time = (TCS_delta_temp/TCS_RAMP_UP)*1000;
%%%%%%%%%%%%%%%%%%%%%%%%

disp('Initializing TCS2...')
% initialize TCS using +tcs2 functions version 2.0.2
com = tcs2.find_com_port;
pause(0.1)
tcs2.init_serial(com);
pause(0.1)
tcs2.init_tcs;
pause(0.1)
%tcs2.set_trigger_in('on');
%pause(0.1)
tcs2.set_max_temperature(65);
pause(0.1)
tcs2.set_stim_temperature(TCS_reftemp);
pause(0.1)
tcs2.set_neutral_temperature(TCS_neutraltemp);
pause(0.1)
tcs2.set_stim_duration(TCS_DURATION, TCS_RAMP_UP);
pause(0.1)
tcs2.enable_temperature_feedback(100)
pause(0.1)
tcs2.get_battery
disp('PRESS ANY KEY TO CONTINUE')
pause()
clc