function set_max_temperature(T)
% set_max_temperature  Set maximum allowed for stimulation temperature.
%    tcs2.set_max_temperature(T)  sets max temperature to T degrees Celsius. Highest allowed value
%    is 70°. Default is 60° - for safety!.
%
%
%  Benvenuto JACOB, UCLouvain, May 2023.


if T > 60
    tcs2.write_serial('Ox70'); % hidden command to allow stimulation up to 70 °C !! Not available for all firwmare version.
end

% tcs2.write_serial('Om650');
tcs2.write_serial(['Om' tcs2.format_xxxx_string(T*10,3,[100 700])]);
