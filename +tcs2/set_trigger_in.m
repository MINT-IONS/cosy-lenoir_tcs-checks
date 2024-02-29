function set_trigger_in(state)
% set_trigger_in enables triggering of the stimulation (0 - 5 V entry)
% state 'on' enables ; 'off' disables trigger-in.
%
%
if strcmp(state,'on')
    tcs2.write_serial('Ose');
    disp('trigger-in enabled.')
elseif strcmp(state,'off')
    tcs2.write_serial('Osd');
    disp('trigger-in disabled.')
end
