function [data] = TCS_stim_trigger(NI,foreperiod_duration,amplitude)

% foreperiod_duration = 0;
NI.Rate = 1000;
% amplitude = 0.4;
stim_duration = 0.1;

%duration_bins
% stim_duration = num_cycles/frequency;
stim_duration_bins = stim_duration*NI.Rate;
foreperiod_duration_bins = foreperiod_duration*NI.Rate;

%
tpx = 1:1:stim_duration_bins;
tpx = (tpx-1)/NI.Rate;

% stimulus sinusoid
tpy = tpx.*0;
% tpy = sin(tpx*2*pi*frequency);

%foreperiod
tpy = [zeros(1,foreperiod_duration_bins) tpy];
tpx = 1:length(tpy);
tpx = (tpx-1)/NI.Rate;

% amplitude 0.4 V
tpy = tpy*amplitude;

% trigger of 100 ms at 5 V
tpy_trigger = zeros(size(tpy));
tpy_trigger(foreperiod_duration_bins+2:foreperiod_duration_bins+0.01*NI.Rate) = amplitude*7;

% fpy (matrix to be sent)
fpy = zeros(length(tpy),3);
fpy(:,1) = tpy_trigger;
fpy(:,3) = tpy_trigger;

%queue the data to NI
queueOutputData(NI.session,fpy);
disp('Data sent to NI');
prepare(NI.session);
[data,time] = NI.session.startForeground();
disp('Trial finished');

end