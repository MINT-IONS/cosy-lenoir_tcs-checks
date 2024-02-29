function disable_temperature_feedback()
% disable_temperature_feedback  Désactive l’affichage régulier des températures courantes
%   tcs2.disable_temperature_feedback  disables the 1Hz (or 100Hz) temperature feedback.

tcs2.write_serial('F');
if tcs2.verbose
    disp('Temperature feedback disabled.')
end
