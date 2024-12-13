function Uw_cmd = set_stim_profil(areas,num_seg,seg_duration,seg_end_temp)
% set_stim_profil set stimulation profil.
%   tcs2.set_stim_profil(areas,numb_seg,seg_duration,seg_eng_temp) sets profil with :
%   areas : number of areas
%   num_seg : number of segments in the profil (0 to 999)
%   seg_duration : list of durations of the segments (1 to 999) [seg_duration_1 seg_duration_2... seg_duration_n]
%   seg_end_temp : list of temperatures target at the end of the segment in degrees/10 ('000' to '600') [seg_end_temp_1 seg_end_temp_2... seg_end_temp_n]
%
%   Example:
%   profil with 3 segments, for all areas, with first 100 ms to reach 60°C, then plateau of
%       200 ms at 60°C, then from 60°C to 32°C in 400 ms
%
%   tcs2.set_stim_profil(11111,3,[100 200 400],[600 600 320])
%


%% Uw-Command - Stimulation Profil
% 'Uwxxxxxnnndddtttdddttt...'   : set stimulation profil using nargin
if nargin < 4
    error('Missing arguments : you must provide the areas + a number of segments + list of segment durations + list temperature at end of segments')
else
    str1 = tcs2.format_xxxx_command('Uwxxxxx',areas,[0 99999]);
    str2 = tcs2.format_xxxx_string(num_seg,3);
    for seg = 1:num_seg
    temp_str3{seg} = [tcs2.format_xxxx_string(seg_duration(seg),3) tcs2.format_xxxx_string(seg_end_temp(seg),3)];
    end
    str3 = [temp_str3{:}];
    Uw_cmd = [str1 str2 str3];
end

tcs2.write_serial(Uw_cmd);