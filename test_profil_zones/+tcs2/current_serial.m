function current_serial(serialObj)
% current_serial  Select current TCS2 device.
%    tcs2.current(serialObj)  where serialObj is a "Serial" object returned by tcs2.init_serial,
%    selects the corresponding TCS2 device as the current one; every subsequent operations will 
%    then be applied to it.
%
%  

global TCS2_SERIAL

TCS2_SERIAL = serialObj;

if tcs2.verbose
    sprintf('Current TCS2 port: %s\n', serialObj.Port)
end
