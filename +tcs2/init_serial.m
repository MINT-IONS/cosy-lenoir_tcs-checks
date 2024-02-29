function comobj = init_serial(comstr)
% init_serial  Initialize TCS2's serial communication.
%   tcs2.init_serial('COM#')  inits connection with TCS2 on COM# port. The TCS2 itself may then be
%   initialised via tcs2.init_tcs.  More than one connection may be open if several TCS2s are used;
%   in which case the current device has to be selected via tcs2.current_tcs <v2.0, Jul 2022>.
%
%   obj = tcs2.init_serial('COM#')  returns serial port object. The serial port object is also
%   stored in the TCS2_SERIAL global variable. Use tcs2.find_com_port to auto find port.
%   If more than one connections have been open, use tcs2.current_serial to select the current one.
%
%   tcs2.init_serial('DUMMY')  inits in dummy mode. To develop sofware without a TCS2.
%
%
%  Examples:
%
%      % Init COM5:
%      tcs2.init_serial('COM5');
%      tcs2.init_tcs;
%
%      % Use tcs2.find_com_port() to find COM port number:
%      com = tcs2.find_com_port;
%      tcs2.init_serial(com);
%      tcs2.init_tcs;
%
%      % Open 2 TCS2s:
%      tcsL = tcs2.init_serial('COM7');
%      tcs2.init_tcs;
%      tcsR = tcs2.init_serial('COM9');
%      tcs2.init_tcs;
%      tcs2.current_serial(tcsL); % use tcs2.current_serial to select the current device


global TCS2_SERIAL

%% Input Arg
if nargin < 1
    msg = 'You must provide the port name,\nexample:  tcs2.init_serial(''COM5'')';
    error(sprintf(msg))
end

%% Init Serial Port
if strcmpi(comstr,'DUMMY')
    disp('Initializing serial connection in DUMMY MODE..')
    TCS2_SERIAL = struct;
    TCS2_SERIAL.Port = 'DUMMY';
    TCS2_SERIAL.BaudRate = 115200;
    TCS2_SERIAL.Status = 'open';
    tcs2.verbose(2); % 2: print serial messages
    warning('DUMMY MODE: Serial messages will be printed in command window, but nothing will be sent.')
    disp(' ')
    
else
    tcs2.verbose(1); % 1: standard verbosity
    
    % Fail Safe Init of COMx Port:
    disp('Initializing serial connection..')
    obj = instrfind('Type','serial','Port',comstr); % search for COMx in already initialised connections..
    
    if isempty(obj) % COMx not already initialised..
        fprintf('..Creating Serial object for %s..\n', comstr)
        TCS2_SERIAL = serial(comstr,'BaudRate',115200);
        
    elseif length(obj) == 1 % COMx has been initialised once before..
        TCS2_SERIAL = obj; % keep existing object
        
    else % Special case: COMx had been initialised several times..
        isopen = strcmp(obj.Status,'open'); %..check which one is in open state..
        if any(isopen)
            TCS2_SERIAL = obj(isopen);
        else
            TCS2_SERIAL = obj(1);
        end
    end
    
    % Open port if needed..
    if strcmpi(TCS2_SERIAL.Status,'open')
        fprintf('..Port %s already open  :-)\n', comstr)
    else
        fprintf('..Opening %s port..\n', comstr)
        fopen(TCS2_SERIAL);
        fprintf('..%s open :-)\n', comstr)
    end
    disp(' ')
    
end

%% Output Object If Requested
if nargout
    comobj = TCS2_SERIAL;
end

