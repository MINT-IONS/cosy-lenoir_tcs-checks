function pc = get_battery
% get_battery  Get battery percentage of charge.

str = tcs2.ask_serial('B');

if isempty(str)
    if nargout
        pc = NaN;
    else
        warning('No response from TCS');
        disp(' ')
    end
    return % <===!!!
end

if str(end) == '%'
    if str(end-3) == '0'
        pc_str = str(end-2:end);
    else
        pc_str = str(end-3:end);
    end
else
    disp(str)
    error('Invalid string!!??')
end

if nargout
    pc = str2num(pc_str(1:end-1));
else
    disp(pc_str);
    disp(' ')
end
