function send_trigger()
% send_trigger  Output trigger now.
%    tcs2.send_trigger  tells TCS2 to outpout a trigger now.
%
%  Example:
%
%       tcs2.set_trigger_out(4); % set line 3
%       tcs2.send_trigger;

tcs2.write_serial('Oo');