function cmd = format_xxxx_command(cmd,value,range)
% format_xxxx_command  Format a TCS command string.
%    cmd = tcs2.format_xxxx_command(cmd,value,range)  in given command string, replaces 'xxxx'
%    by given numerical value.
%
%  Examples:
%
%       tcs2.format_xxxx_command('Nxxx',320,[200 400])   % -> outputs: 'N320'
%       tcs2.format_xxxx_command('C0xxx',480,[100 600])  % -> outputs: 'C0480'


n = sum(cmd=='x');

xxxx = tcs2.format_xxxx_string(value,n,range);

cmd(cmd=='x') = xxxx;
