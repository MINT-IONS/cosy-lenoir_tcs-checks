function set_neutral_temperature(T)
% set_neutral_temperature  Set stimulation temperature.
%    tcs2.set_neutral_temperature(T)  sets temperature. T is the temperature in degrees Celsius,
%    ranging from 20.0° to 40.0°, with a precision of 0.1°.
%
%   Examples:
%
%       tcs2.set_neutral_temperature(32); % Arthur Courtin's setting


%% N-Command - Neutral Temperature
% 'Nxxx'	   : set neutral temperature in 1/10 degrees ('xxx'='200' to '400')
tcs2.write_serial(['N' tcs2.format_xxxx_string(T*10,3,[100 600])]);
