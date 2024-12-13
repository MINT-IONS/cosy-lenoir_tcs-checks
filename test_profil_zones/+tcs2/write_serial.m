function write_serial(str)
% write_serial  Write to port initialized by tcs2.init
%   write_serial(str)

global TCS2_SERIAL

if isempty(TCS2_SERIAL)
    error('Serial connection not initialized. Please run tcs2.init_serial first.')
end

if tcs2.verbose >= 2
    disp(['sending: "' str '"'])
end

if ~strcmp(TCS2_SERIAL.Port,'DUMMY')
    fwrite(TCS2_SERIAL,str,'uchar');
end
