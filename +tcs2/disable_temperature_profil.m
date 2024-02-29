function disable_temperature_profil()
% disable_temperature_profil disables temperature profil to be sent to n areas.
%
%
tcs2.write_serial(tcs2.format_xxxx_command('Uexxxxx',00000,[0 99999]));
disp('Temperature profil disabled.')

end
