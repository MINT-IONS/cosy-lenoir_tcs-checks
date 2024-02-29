function enable_temperature_feedback(Hz)
% enable_temperature_feedback  Désactive l’affichage régulier des températures courantes
%   tcs2.enable_temperature_feedback  enables temp feedback at 1 Hz.
%
%   tcs2.enable_temperature_feedback(100)  enables temp feedback at 100 Hz.

if ~nargin
    Hz = 1;
end

switch Hz
    case 1
        tcs2.write_serial('Oa');
        disp('Temperature feedback enabled (1Hz).')
    case 100
        tcs2.write_serial('Ob');
        disp('Temperature feedback enabled at 100Hz.')
    otherwise
        error('Invalid frequency. Valid frequencies are 1 or 100 Hz.')
end
