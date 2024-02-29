%help
function result = Copy_of_CHEP_foot_hand_ratings_TCS_PROD(session_string, subject_string)

rng shuffle

%PARAMETERS
%debug?
debug = 1;

%session string
% session_string = 'SESSION2';
%subject string
% subject_string = 'SUBJECT15bis';

%CHEP
CHEP = 'CHEP';

%initialize TCS
if debug == 0
    disp('Initialize TCS')
    TCS_initialize
    disp('TCS Initialized')
end

%init variables
TCS_reftemp = 62;

result = [];
filename = [subject_string ' ' session_string ' ' CHEP ' ' datestr(now,'mmmm-dd-yyyy-HH-MM-SS')];
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
temp_feedback = {};

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
                temperature_feedback
                temp_feedback{end+1} = temp_feed;
                clear temp_feed temporary
            end
        end

        %collect NRS response from participant
        NRS = input('Rating block of 5 stimuli on FOOT (0-100)','s');
        foot_ratings{end+1} = NRS;

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
                temperature_feedback
                temp_feedback{end+1} = temp_feed;
                clear temp_feed temporary
            end
        end

        %collect NRS response from participant
        NRS = input('Rating block of 5 stimuli on HAND (0-100)','s');
        hand_ratings{end+1} = NRS;

        disp(['BLOCK finished: ' num2str(block_count)])

        pause()

    end

    ok = 0;

end

disp('We are finished!')

result.hand_ratings = hand_ratings;
result.foot_ratings = foot_ratings;
result.temp_feedback = temp_feedback;
save(filename,'result')

end
