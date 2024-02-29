function str = clear_serial()
% clear_serial  Clear serial queue.
%   tcs2.clear_serial

str = tcs2.read_serial;
while ~isempty(str)
    pause(0.200)
    str = tcs2.read_serial;
end
