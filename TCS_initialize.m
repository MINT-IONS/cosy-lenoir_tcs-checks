
%%%%%%%%%%%%%%%%%%%%%%%%
% in initialize
% %TCS com port
% TCS_comport = 'COM5';
% %TCS neutral temp
% TCS_neutraltemp = 35;
% %TCS maximum temp
% TCS_maxtemp = 70;

TCS_DURATION = 250; % ms
TCS_RAMP_UP = 300; % °C/s
TCS_reftemp = 62;
TCS_neutraltemp = 35;
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
tcs2.write_serial('B')
disp('PRESS ANY KEY TO OCNTINUE')
pause()
clc