function set_stim_temperature(T)
% set_stim_temperature  Set stimulation temperature.
%    tcs2.set_stim_temperature(T)  sets temperature. T is the temperature in degrees Celsius,
%    ranging from 10.0° to 60.0°, with a step of 0.1°.
%
%   Examples:
%
%       % Warm:
%       tcs2.set_stim_temperature(60); 
%       tcs2.stimulate;
%
%       % Cold:
%       tcs2.set_stim_temperature(10); 
%       tcs2.stimulate;

%% Area Parameter
s = '0'; % all areas (always - we have no need for areas currently)

%% C-Command - Stimulation Temperature
% 'Csxxx'   : set stimulation temperature in 1/10 degrees ('s'='0'(all areas) or '1' to '5', 'xxx'='100' to '600')
tcs2.write_serial(['C' s tcs2.format_xxxx_string(T*10,3,[100 700])]);