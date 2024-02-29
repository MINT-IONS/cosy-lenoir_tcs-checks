function str = get_help()
% get_help  Get help from TCS2
%   tcs2.get_help  prints TCS2's commands help in command window.
%
%   str = tcs2.get_help  outputs doc string in a variable.
%
%TCS2 A:
% Firmware: 008 Sep  2 2021 14:17:28
% Probe ID: 2D 0F C9 C5 2F 00 00 51
% Probe TYPE: 003
% 
% Command list:
% 'H'	   : help
% 'Nxxx'	   : set neutral temperature in 1/10 degrees ('xxx'='200' to '400')
% 'G'	   : calibrate neutral temperature ( after few seconds return 'Nxxx' with xxx = neutral temperature in 1/10 degrees ) 
% 'Sxxxxx'  : enable/disable area 1 to 5 (x='1'=enable or '0'=disable)
% 'Csxxx'   : set stimulation temperature in 1/10 degrees ('s'='0'(all areas) or '1' to '5', 'xxx'='100' to '600')
% 'Vsxxxx'  : set stimulation speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
% 'Rsxxxx'  : set return speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
% 'Dsxxxxx' : set stimulation Duration in ms ('s'='0'(all areas) or '1' to '5', 'xxxxx'='00001' to '99999')
% 'Txxxyyy' : set Trigger number and duration (number 'xxx'='001' to '255', duration 'yyy'='010' to '999')
% 'P'	   : display stimulation Parameters (global and for each area)
% 'L'	   : start stimuLation
% 'A'	   : Abort current stimulation or exit 'follow mode'
% 'F'	   : mute mode, disable display of temperatures between and during stimulations
% 'Yxxxx'   : set the duration of temperature display during stimulation in ten ms ('xxxx'='0000' to '9999')
% 			 if set to '0000' (default state) displays temperatures during the entire stimulation
% 'Oa'	   : enable temperatures display between stimulations ( 1Hz, active by default )
% 'Ob'	   : enable temperatures display during stimulations ( 100Hz, active by default )
% 'Oc'	   : reset stimulator
% 'Od'	   : 'follow mode': probe goes to the setpoint temperature and remains there as long as the setpoint does not change.
% 'Omxxx'   : Defines a maximum stimulation temperature ('xxx' 1/10 degrees). 'C' command is limited to this temperature.
% 'Ovsxxxxx': set stimulation speed in 1/100 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxxx'='00001' to '99999')
% 'Otsxxxx' : set stimulation temperature in 1/100 degrees ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '6000')
% 'Oe'	   : display currEnt temperatures for neutral and area 1 to 5 in 1/100 degrees
% 'Os'	   : allows a stimulation to be triggered via the trigger in (stim input)
% 'Oo'	   : Output trigger
% 'B'	   : display Battery voltage and % of charge
% 'Ix'	   : enable/disable Integral term, 'x'='1' : enable(default state), 'x'='0' : disable
% 'E'	   : display currEnt temperatures for neutral and area 1 to 5 in 1/10 degrees
% 'K'	   : get button 1&2 state ( CR+'00' both released, CR+'11' both pressed, CR+'10' only button 1 pressed,...)
% 'Q'	   : get error state ( return 'xxxxxx', for each zone+neutral: 'x'=0:OK,'x'>1:ERROR )
% 'Ur'	   : display temperature profile for each area: area number(1..5), profile enabled, number of points defined, points list
% 'Uwxxxxxnnndddtttdddttt...' : User defined temperature profile, defined by segments of variable duration
% 			 'xxxxx': areas defined ('11111' all areas, '10000' just area 1, ...), 'nnn': number of segments ('000' to '999')
% 			 'dddttt': list of duration of segment in ten of ms ('001' to '999') and temperature at end of segment ('000' to '600')
% 'Uexxxxx' : enable/disable temperature profile for each area (x='1'=enable or '0'=disable=default)
% 'Xr'	   : clock read hour and date, return hhmmssddmmyy
% 'Xwhhmmssddmmyy' : clock write hour and date ( hh:heure, mm:minute, ss:seconds, dd:day, mm:month, yy:year )
% 'Zdddfff' : Buzzer ddd: duration in 10x ms, fff: frequency in 10x Hz

tcs2.write_serial('H');
pause(.500)
str = tcs2.read_serial;

%% TCS2 B:
% Firmware: 012 Jun 20 2022 11:07:51
% Probe ID: 2D DD 40 C1 3A 00 00 B2
% Probe TYPE: 003
% 
% Command list:
% 'H'	   : help
% 'Nxxx'	   : set neutral temperature in 1/10 degrees ('xxx'='200' to '400')
% 'G'	   : calibrate neutral temperature ( after few seconds return 'Nxxx' with xxx = neutral temperature in 1/10 degrees ) 
% 'Sxxxxx'  : enable/disable area 1 to 5 (x='1'=enable or '0'=disable)
% 'Csxxx'   : set stimulation temperature in 1/10 degrees ('s'='0'(all areas) or '1' to '5', 'xxx'='100' to '600')
% 'Vsxxxx'  : set stimulation speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
% 'Rsxxxx'  : set return speed in 1/10 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '9999')
% 'Dsxxxxx' : set stimulation Duration in ms ('s'='0'(all areas) or '1' to '5', 'xxxxx'='00001' to '99999')
% 'Txxxyyy' : set Trigger number and duration (number 'xxx'='001' to '255', duration 'yyy'='010' to '999')
% 'P'	   : display stimulation Parameters (global and for each area)
% 'L'	   : start stimuLation
% 'A'	   : Abort current stimulation or exit 'follow mode'
% 'F'	   : mute mode, disable display of temperatures between and during stimulations
% 'Yxxxx'   : set the duration of temperature display during stimulation in ten ms ('xxxx'='0000' to '9999')
% 			 if set to '0000' (default state) displays temperatures during the entire stimulation
% 'Oa'	   : enable temperatures display between stimulations ( 1Hz, active by default )
% 'Ob'	   : enable temperatures display during stimulations ( 100Hz, active by default )
% 'Oc'	   : reset stimulator
% 'Od'	   : 'follow mode': probe goes to the setpoint temperature and remains there as long as the setpoint does not change.
% 'Omxxx'   : Defines a maximum stimulation temperature ('xxx' 1/10 degrees). 'C' command is limited to this temperature.
% 'Ovsxxxxx': set stimulation speed in 1/100 degrees per seconds ('s'='0'(all areas) or '1' to '5', 'xxxxx'='00001' to '99999')
% 'Otsxxxx' : set stimulation temperature in 1/100 degrees ('s'='0'(all areas) or '1' to '5', 'xxxx'='0001' to '6000')
% 'Oe'	   : display currEnt temperatures for neutral and area 1 to 5 in 1/100 degrees
% 'Os'	   : allows a stimulation to be triggered via the trigger in (stim input)
% 'Oo'	   : Output trigger
% 'B'	   : display Battery voltage and % of charge
% 'Ix'	   : enable/disable Integral term, 'x'='1' : enable(default state), 'x'='0' : disable
% 'E'	   : display currEnt temperatures for neutral and area 1 to 5 in 1/10 degrees
% 'K'	   : get button 1&2 state ( CR+'00' both released, CR+'11' both pressed, CR+'10' only button 1 pressed,...)
% 'Q'	   : get error state ( return 'xxxxxx', for each zone+neutral: 'x'=0:OK,'x'>1:ERROR )
% 'Ur'	   : display temperature profile for each area: area number(1..5), profile enabled, number of points defined, points list
% 'Uwxxxxxnnndddtttdddttt...' : User defined temperature profile, defined by segments of variable duration
% 			 'xxxxx': areas defined ('11111' all areas, '10000' just area 1, ...), 'nnn': number of segments ('000' to '999')
% 			 'dddttt': list of duration of segment in ten of ms ('001' to '999') and temperature at end of segment ('000' to '600')
% 'Uexxxxx' : enable/disable temperature profile for each area (x='1'=enable or '0'=disable=default)
% 'Xr'	   : clock read hour and date, return hhmmssddmmyy
% 'Xwhhmmssddmmyy' : clock write hour and date ( hh:heure, mm:minute, ss:seconds, dd:day, mm:month, yy:year )
% 'Zdddfff' : Buzzer ddd: duration in 10x ms, fff: frequency in 10x Hz
% 'OiI'	: program Irm room extension cable
% 'OiC'	: program Control room extension cable
% 'Oim'	: measure temperature of extension cable ( takes about 1.5s )
% 'Oit'	: display temperature of extension cable
