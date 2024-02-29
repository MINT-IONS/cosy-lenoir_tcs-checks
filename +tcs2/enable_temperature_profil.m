function enable_temperature_profil(n)
% enable_temperature_profil enables customed temp profils to be sent to n areas
% 
%

tcs2.write_serial(tcs2.format_xxxx_command('Uexxxxx',n,[0 99999]));
disp('Temperature profil enabled.')

end
