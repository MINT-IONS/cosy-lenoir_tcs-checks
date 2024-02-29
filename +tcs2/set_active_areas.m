function set_active_areas(n)
% set_active_areas  Enable/disable area 1 to 5.
%    tcs2.set_active_areas(n)  activates area(s) number n,  n being a number or a
%    vector of numbers from 1 to 5.
%
%    tcs2.set_active_areas all  is the same than  tcs2.set_active_areas(1:5)
%
%
%  Benvenuto JACOB, UCLouvain, Jul 2022.

if strcmpi('all',n)
    n = 1:5;
end

%% S-Command - Enable Areas
% 'Sxxxxx'  : enable/disable area 1 to 5 (x='1'=enable or '0'=disable)
cmd = 'S00000';
cmd(n+1) = '1';

tcs2.write_serial(cmd);
