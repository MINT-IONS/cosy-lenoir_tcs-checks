function xxxx = format_xxxx_string(value,n,range)
% format_xxxx_string  Format "xxxx" part of a TCS command string.
%   xxxx = tcs2.format_xxxx_string(value,n)  converts value to n digit string.
%   xxxx = tcs2.format_xxxx_string(value,n,range)  checks that value is inside range.

value = round(value);
if nargin >= 3
    if (value < range(1)) | (value > range(2))
        error('Value (%d) outside range (%d to %d).',value,range(1),range(2))
    end
end

format = ['%' int2str(n) 'd'];

xxxx = sprintf(format,value);
xxxx(xxxx==' ') = '0';
