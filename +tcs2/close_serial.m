function close_serial
% close_serial  Close TCS2's serial communication.

global TCS2_SERIAL

try
    fclose(TCS2_SERIAL)
end
delete(TCS2_SERIAL)

TCS2_SERIAL = [];
