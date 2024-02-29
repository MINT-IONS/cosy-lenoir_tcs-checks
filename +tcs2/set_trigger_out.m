function set_trigger_out(n,d)
% set_trigger_out  Set trigger-out parameters
%   set_trigger_out(n)  sets trigger number from 1 to 255 (see manual below)
%
%   set_trigger_out(n,duration)  defines trigger width in ms. Allowed range: 10ms to 999ms.
%
%  Example:
%
%     tcs2.set_trigger_out(1);   % enables trigger on line 1
%     tcs2.set_trigger_out(2);   % enables trigger on line 2
%     tcs2.set_trigger_out(4);   % enables trigger on line 3
%     tcs2.set_trigger_out(8);   % enables trigger on line 4
%     tcs2.set_trigger_out(255); % enables trigger on all lines
%     tcs2.set_trigger_out(0);   % disables trigger %<NB: what about 0??? Test it!!>
%
%
%% 3. Connexion Trigger (TCS2 Manual, p.13)
% ======================
% La sortie trigger (connecteur 9, Figure 16) utilise  un  registre  à  décalage  74HC595  qui  a  sa  propre
% alimentation 5V isolé du stimulateur TCS II. Par défaut, toutes les sorties trigger sont à 0 V.
% Les sorties trigger activées passent à 5 V pendant 10ms au début de la stimulation (initiée par la commande 
% « L »). Les lignes trigger activées correspondent  en  binaire  au  numéro  de  trigger  entré  en  paramètre  
% (par exemple : 
% • ‘001’ active la sortie trigger d0 <sortie #1>
% • ‘002’ active la sortie trigger d1 <sortie #1>
% • ‘255’ active toutes les sorties trigger de d0 à d7 simultanément. 
%  Des résistances séries de 270 ? ont été intallées sur les sorties Trigger pour limiter le courant en sortie en
% cas d’erreur de branchement.
%
% ground = line 9
%
%
%% Connection of devices to trigger interface (Micromed (EEG) Manual, p.18)
% ============================================
% The BQ USB PLUS interface is endowed of two RCA connections (one input, one output) for 
% exchange of trigger with external devices. Input triggers are added to the acquired signal and 
% output triggers are sent to the external devices (e.g. photic stimulators) according to the 
% settings in the Software. Refer to the software user manual for further information.
% The BQ USB MULTI and BOX TERMINAL MULTI interfaces, instead, are endowed of three RCA 
% connections (two input, one output).
% Trigger input and output are isolated. However, the overall system must comply with IEC 
% 60601-1 standard, that is, if the connected device is compliant with IEC 60601-1 it can enter 
% the patient area, on the contrary it must be kept out. 
% Output trigger characteristics
% Amplitude: (0-5V) positive pulses. Pulse polarity can be reversed by inverting the cable pole.
% Duration: 30µs 
% Output isolated with pulse transformer.
% Input trigger characteristics
% Amplitude: (0-5V) 
% Trigger on rising edge. It is possible to accept falling edge pulse inverting the cable pole.
% Maximum trigger frequency is fs/2 (1 trigger every 2 sample max).
% No minimum trigger duration since the edge is recognized (10µs minimum is suggested). 
% Isolated trigger with pulse Transformer.


%% Input Args
if nargin == 0
    error('Missing argument: you must provide a number between 1 and 255') %<NB: what about 0??? Test it!!>
elseif nargin == 1
    d = 10; % keep default of 10 ms (cannot be shorter!?)
end

%% Build Command String
% 'Txxxyyy' : set Trigger number and duration (number 'xxx'='001' to '255', duration 'yyy'='010' to '999')
xxx = tcs2.format_xxxx_string(n,3,[0 255]);  %<NB: what about 0??? Test it!!>
yyy = tcs2.format_xxxx_string(d,3,[10 999]);
tcs2.write_serial(['T' xxx yyy]);
