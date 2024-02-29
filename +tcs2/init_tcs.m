function init_tcs
% init_tcs  


%% Check If TCS2 Is Responding
pause(0.100)
ok = tcs2.check_serial;


%% Enable (Disable) TCS2 Temperature Feedback
% tcs2.disable_temperature_feedback;
tcs2.enable_temperature_feedback(100);

pause(.100)
tcs2.clear_serial;


%% Set Defaults
% We'll use Arthur's defaults:

% Duration of temperature display
tcs2.write_serial('Y0000'); %(default)
%  Set the duration of temperature display during stimulation in ten ms ('xxxx'='0000' to '9999')
% if set to '0000' (default state) displays temperatures during the entire stimulation
%  Durée d’affichage (ms) des températures des 5 zones à pa
% début de la stimulation (affichage à 200Hz). Cela permet de 
% vérifier les températures pendant la stimulation.

% Trigger In:
% tcs2.write_serial('Os');     % allows a stimulation to be triggered via the trigger in (stim input)

% Neutral temperature:
tcs2.write_serial('N320');   % set neutral temperature in 1/10 degrees ('xxx'='200' to '400')

% Areas:
% - Disable per-area stuffs:
% tcs2.write_serial('Ue00000');% enable/disable temperature profile for each area (x='1'=enable or '0'=disable=default)
% - Enable all area (they are all disabled by default!):
tcs2.write_serial('S11111'); % enable/disable area 1 to 5 (x='1'=enable or '0'=disable)
% Les valeurs par défaut de la commande S sont '00000'. Par conséquent, toutes les zones sont désactivées à l’allumage du TCS II. 
% Pour faire des essais de stimulation par le Com Série, il faut activer au moins une zone (!!!)

% Stim Duration: 
% tcs2.set_stim_duration(200,300,300); % 200ms, 300°/s, 300°/s
% (NB use "tcs2.set_stim_duration" for later work)

%% Say Hi
fprintf('%d pc battery charge left.\n', tcs2.get_battery)
disp('TCS2 initialized :-)')
disp(' ')

tcs2.clear_serial;

