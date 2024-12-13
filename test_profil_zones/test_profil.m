TCS2_COM = tcs2.find_com_port;

% parameters for stimulation profiles
areas = 11000; % zones 1 and 2
num_seg = 3; % ramp-up + plateau + ramp down
seg_duration = [100 10 500]; % in tens of ms
% set temperatures depending on right and left temperature obtained from the calibration task
seg_end_temp(:,1) = [32*10 52*10 52*10]; % in 1/10°C

COM = tcs2.init_serial(TCS2_COM);
tcs2.current_serial(COM)

% set neutral baseline temperature
tcs2.set_neutral_temperature(32);
pause(0.1)

% set max temperature to 62°
tcs2.write_serial('Ox62');
tcs2.write_serial('Om620');
pause(0.1)

% enable temperature profile
tcs2.enable_temperature_profil(11000) % zones 1 and 2
pause(0.1)

% disable temperature feedback
tcs2.enable_temperature_feedback(100)

% set profile
tcs2.set_stim_profil(areas,num_seg,seg_duration,seg_end_temp(:,1));

% stimulate
tcs2.stimulate