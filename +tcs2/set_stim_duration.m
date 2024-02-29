function set_stim_duration(duration_ms,ramp_up,ramp_down)
% set_stim_duration  Set temporal parameters of the stimulation. (All areas.)
%    tcs2.set_stim_duration(duration_ms,ramp_up_ms,ramp_down_ms)  sets stimulation duration in milliseconds
%    and sets ramp-up and ramp-down in deg/s (precision: 1/10 deg/s). 
%
%    tcs2.set_stim_duration(duration_ms)  sets stim duration only, letting ramp up/down parameters unchanged.
%
%
%  Examples: 
%
%        % Arthur Courtin's settings, 2021:
%        tcs2.set_stim_duration(200,300,300); % 200ms, 300°/s, 300°/s
%
%        % Geuters et al. 2017:
%        tcs2.set_stim_duration(1500,70,40); % 1.5s, 70°/s, 40°/s


%% Area Parameter
s = '0'; % all areas (always - we have no need for areas currently)

%% D-Command - Stimulation Duration
%'Dsxxxxx' : set stimulation Duration in ms ('s'='0'(all areas) or '1' to '5', 'xxxxx'='00001' to '99999')
tcs2.write_serial(['D' s tcs2.format_xxxx_string(duration_ms,5,[1 99999])]);

%% V-Command - Ramp-Up
if nargin >= 2
    %'Vsxxxx'  : set stimulation speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
    tcs2.write_serial(['V' s tcs2.format_xxxx_string(ramp_up*10,4,[1 9999])]);
end

%% R-Command - Ramp-Down
if nargin >= 3
    %'Rsxxxx'  : set return speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
    tcs2.write_serial(['R' s tcs2.format_xxxx_string(ramp_down*10,4,[1 9999])]);
end
