function answer_str = ask_serial(command_str)
% ask_serial  Send string to TCS2 and return answer.
%   answer_str = tcs2.ask_serial(command_str)

tcs2.clear_serial;

tcs2.write_serial(command_str);
pause(.100)
answer_str = tcs2.read_serial;