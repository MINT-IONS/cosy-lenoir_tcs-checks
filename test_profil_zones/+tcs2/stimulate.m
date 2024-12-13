function stimulate
% stimulate  Start stimulation
%   tcs2.stimulate  triggers stimulation with current parameters.

if tcs2.verbose >= 2
    disp('Stimulating with following params:')
    tcs2.ask_serial('P');
end

tcs2.write_serial('L');