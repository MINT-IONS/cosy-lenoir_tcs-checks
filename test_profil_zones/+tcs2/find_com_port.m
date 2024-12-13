function COM = find_com_port()
% find_com_port  Find COM# port number.
%    COM = find_com_port  returns COM port string (e.g. 'COM8'). If several
%    port are found, the last one is taken. If none are found, an error is 
%    thrown. Physical ports (COM1, COM2) are always ignored.
%
%

VERBOSE = 1;

if VERBOSE
    disp('find_com_port:')
end

info = instrhwinfo('serial');

ports = info.SerialPorts;

if isempty(ports)
    error('No COM port found.')
else
    COM = ports{end};
    if strcmpi(COM,'COM1') | strcmpi(COM,'COM2')
        error(['No COM port found, other than physical port (' COM ').'])
    elseif VERBOSE
        disp('Found serial ports: ')
        disp(ports)
    end
    if nargout==0
        clear COM
    end
end
