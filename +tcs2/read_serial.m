function str = read_serial()
% read_serial  Read port initialized by tcs2.init
%   tcs2.read_serial  reads all chars availables from port; prints them in command window.
%
%   str = tcs2.read_serial  outputs in variable.

global TCS2_SERIAL

if isempty(TCS2_SERIAL)
    error('Serial connection not initialized. Please run tcs2.init_serial first.')
elseif strcmp(TCS2_SERIAL.Port,'DUMMY')
    str = '';
    return
end

str = '';

while 1
    n = get(TCS2_SERIAL,'BytesAvailable');
    if n
        str = [str char(fread(TCS2_SERIAL,n,'uchar'))'];
        if n==512
            pause(.100)
        end
    else
        break
    end
end

if (tcs2.verbose >= 2) && ~isempty(str)
    fprintf('receiving: ')
    disp(str)
end
