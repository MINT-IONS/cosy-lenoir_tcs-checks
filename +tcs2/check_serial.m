function ok = check_serial
% check_serial  Check TCS2 connected and responding.
%    ok = tcs2.check_serial  returns true if TCS2 answers as expected.
%    Temperatue feedback is assumed to have been disabled.

disp('Checking connection with TCS2..')

%% Send "get Battery" command
answer = tcs2.ask_serial('B');

%% Check that we got a valid answer
exp = '[0-9]+\.[0-9]+v [0-9]+\%';
ok = ~isempty(regexp(answer,exp,'once'));

%% Print Feedback
if ok
    disp('..TCS2 connected and responding :-)')
else
    if isempty(answer)
        warning('..No response from TCS2! :-(')
    else
        disp('Unexpected answer from TCS2 ???:')
        disp(answer)
        warning('Unexpected answer from TCS2 !?!?')
    end
end
