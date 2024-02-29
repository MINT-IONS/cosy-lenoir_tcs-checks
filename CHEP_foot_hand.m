%To launch enter into parenthesis (subject number, session number,
%'baseline/poststim')

function result = CHEP_foot_hand(subject_number, session_number, block_string)

subject_number = 1;
session_number = 1;
block_string = 'baseline';

rng shuffle

%PARAMETERS
%debug?
debug = 0;

%session string
% session_string = 'SESSION2';
%subject string
% subject_string = 'SUBJECT15bis';
%block
%block = 'baseline'
%CHEP
%CHEP = 'CHEP';

%initialize TCS
if debug == 0
    disp('Initialize TCS')
    TCS_initialize
    disp('TCS Initialized')
end

%init variables
TCS_reftemp = 62;

result = [];
filename = strcat(['SUBJECT',num2str(subject_number),'_SESSION', num2str(session_number),'_',block_string,' ',datestr(now,'mmmm-dd-yyyy-HH-MM-SS')]);
disp(filename)

trial_count_hand = 0;
trial_count_foot = 0;

trial_count_hand_block = 0;
trial_count_foot_block = 0;

block_count = 0;

trial_switch = 1;
ok = 1;

hand_ratings = {};
foot_ratings = {};
hand_temp_feedback = {};
foot_temp_feedback = {};

while ok == 1

    for block_count = 1:8

        disp(['STARTING BLOCK : ' num2str(block_count)]);

        pause()

        %CHEP foot

        disp('STIMULATE FOOT');

        pause()

        for trial_count_foot_block = 1:5

            trial_count_foot = trial_count_foot+1;

            disp(['BLOCK : ' num2str(block_count)])
            disp(['TRIAL : ' num2str(trial_count_foot_block)])
            disp(['Stimulus on FOOT : ' num2str(TCS_reftemp)])
            pause()
            pause(rand()*0.5+0.5)
            if debug == 0
                tcs2.set_trigger_out(2,10)
                tcs2.stimulate
                get_temperature_feedback
                foot_temp_feedback{end+1,1} = temperature_feedback;
                clear temperature_feedback temporary
            end
        end

        %collect NRS response from participant
        NRS = input('Rating block of 5 stimuli on FOOT (0-100)','s');
        foot_ratings{end+1} = NRS;
        result.foot_ratings = foot_ratings;

        %CHEP hand

        disp('STIMULATE HAND')

        pause()

        for trial_count_hand_block = 1:5

            trial_count_hand = trial_count_hand+1;

            disp(['BLOCK : ' num2str(block_count)])
            disp(['TRIAL : ' num2str(trial_count_hand_block)])
            disp(['Stimulus on HAND : ' num2str(TCS_reftemp)])
            pause()
            pause(rand()*0.5+0.5)
            if debug == 0
                tcs2.set_trigger_out(1,10)
                tcs2.stimulate
                get_temperature_feedback
                hand_temp_feedback{end+1} = temperature_feedback;
                clear temperature_feedback temporary
            end
        end

        %collect NRS response from participant
        NRS = input('Rating block of 5 stimuli on HAND (0-100)','s');
        hand_ratings{end+1} = NRS;
                
        disp(['BLOCK finished: ' num2str(block_count)])

        pause()

    end

    ok = 0;
    
result.foot_temp_feedback = foot_temp_feedback;    
result.foot_ratings = foot_ratings;
result.hand_temp_feedback = hand_temp_feedback;
result.hand_ratings = hand_ratings;

save(filename,'result')
    
end

disp('We are finished!')

end
