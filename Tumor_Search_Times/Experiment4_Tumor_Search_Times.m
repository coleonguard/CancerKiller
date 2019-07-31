%% Setting up
close all;
clear all;

%% Obtaining User Input
Info = {'Initials', 'Full Name','Gender [1=Male, 2=Female, 3=Other]','Age','Ethnicity', 'Years of Experience'};
dlg_title = 'Subject Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);

existingData = load('subjectNumber.mat');
subjectNumber = existingData.subjectNumber + 1;
save('subjectNumber', 'subjectNumber');

threshold = .66;
number_of_trials = 10;
response = zeros(number_of_trials,1);%if the user is right or wrong

s1 = [1,0,0;1,0,0;1,0,0]; % Matrix for when the first main shape is shown
s2 = [0,1,0;0,1,0;0,1,0]; % Matrix for when the second main shape is shown
s3 = [0,0,1;0,0,1;0,0,1];% Matrix for when the third main shape is shown

actualresponse = zeros(3,3,number_of_trials);%what the user actually responded
previousstimuli = zeros(number_of_trials,1);
comparativeincorrect = zeros(3,3);

comparativediagonal1 = [1,0,0;0,0,0;0,0,0]; %the prev matrix of A shape
comparativediagonal2 = [0,0,0;0,1,0;0,0,0]; %the prev matrix of B shape
comparativediagonal3 = [0,0,0;0,0,0;0,0,1]; %the prev matrix of C shape

isserialdependence = zeros(1,number_of_trials);
actualaccuracy = 0;
%% Load Screens

Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0,[128 128 128], [0,0,300,300]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

window_w = rect(3); % defining size of screen
window_h = rect(4);

x_center = window_w/2;
y_center = window_h/2;

cd('shape_Stimuli');

%% showing random morph image behind noise

for f = 1:147
    Mask_Plain = imread([num2str(f) 'mask.JPG']); %Load black circle on white background.
    Mask_Plain = 255-Mask_Plain(:,:,1); %use first layer
    tmp_bmp = imread(['Morph' num2str(f) '.JPG']);
    tmp_bmp(:,:,4) = Mask_Plain;
    tid(f) = Screen('MakeTexture', window, uint8(tmp_bmp));
    
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, sprintf('%d%%',round(f*(100/147))), 120, y_center+412.9950); % Write text to confirm percentage complete
    
    Screen('DrawText', window, 'Hello! Welcome to the Tumor Detection Experiment.', x_center-238, y_center)
    Screen('DrawText', window, 'In the following screen, a random shape representing a tumor will be displayed.', x_center-378, y_center + 25)
    Screen('DrawText', window, 'After the random shape has been displayed, another tumor will be displayed.', x_center-648, y_center + 50)
    Screen('DrawText', window, 'Please click 1 if the two tumors were the same, and 0 if they were NOT the same!', x_center - 668, y_center + 75)
    Screen('Flip', window); % Display text -- loading stuff
end


img_w = size(tmp_bmp, 2)/4; % width of pictures
img_h = size(tmp_bmp, 1)/4; % height of pictures
trial_num = 1;

%% Experiment 4 Specifics
reactionTimes = zeros(number_of_trials, 1); % Store how long the user took to react
tumorClasses = zeros(number_of_trials, 1); % Store which class was on the prompt each trial
tumorsShown = zeros(number_of_trials, 1);
yesOrNo = zeros(number_of_trials, 1); % Store which option the user checked

for trial_num = 1:number_of_trials
    HideCursor();
    random_location = [0,0]; %making a random location for the image to be displayed at
    random_location(1) = randi([ceil(img_w/2) floor(window_w-(img_w/2))]);
    random_location(2) = randi([ceil(img_h/2) floor(window_h-(img_h/2))]);
    shape_num = 147; % total number of stimuli
    randshape = randi(shape_num); % making sure the shape is different each time (random)
    % changing the colors of the noise to be closer to the background color of the image
    
    greyorblack = round(rand(window_w, window_h)) * 255;
    for cols = 1:window_h
        for rows = 1:window_w
            if greyorblack(rows,cols) == 255 %white (light)
                greyorblack(rows,cols) = 75;
            elseif greyorblack(rows, cols) == 0 %black (dark)
                greyorblack(rows,cols) = 45;
            end
        end
    end
    mask_mem = resizem(greyorblack, [2 * rect(4), 2 * rect(3)]);
    for hi = 1:3
        background(:,:,hi) = mask_mem;
    end
    background(:,:,4) = ones(2 * rect(4),2 * rect(3)) * 200;

    tumorClass = randi(3) * 49; % Choose one of the three tumor classes randomly for each prompt for each trial
    tumorClasses(trial_num) = tumorClass;
    Screen('Flip', window);
    tumorClassLoc = [x_center-img_w/2, y_center-img_h/2, x_center+img_w/2, y_center+img_h/2];    
    Screen('DrawTexture', window, tid(tumorClass), [], tumorClassLoc);
    Screen('Flip', window);
    WaitSecs(1);

    tumorShown = randi(3) * 49; % Choose one of the three tumor classes randomly to show in the screens with noise (which user reacts to)
    tumorsShown(trial_num) = tumorShown;

    mask_mem_Tex = Screen('MakeTexture', window, background);  % make the mask_memory texture
    Screen('DrawTexture', window, tid(tumorShown), [], ...
        [random_location(1)-img_w/2 random_location(2)-img_h/2 random_location(1)+img_w/2 random_location(2)+img_h/2]); % displaying images centered at the random point
    Screen('DrawTexture',window, mask_mem_Tex); % draw the noise texture
    
    Screen('Flip', window);
    
    WaitSecs(0.3);
    ShowCursor()
    Screen('DrawTexture',window, mask_mem_Tex); % draw the noise texture
    
    Screen('Flip', window);

    tic; % Start a stopwatch to get reaction times

    %% Getting User Feedback
    clickedYet = false;
    while ~clickedYet
        [keyIsDown, secs, keyCode] = KbCheck;
        
        if keyIsDown == 1 && (keyCode(11) == 1 || keyCode(20) == 1)
	    reactionTimes(trial_num) = toc;
	    yesOrNo(trial_num) = KbName(keyCode);
        clickedYet = true;
        end
    end
       
end
Serial_Dependence = strcat(num2str(totalserials), '/', num2str(number_of_trials-1)); %shows the number w/ serial dependence
Serial_Dependence
Accuracy = strcat(num2str(actualaccuracy), '/', num2str(number_of_trials-1)); %shows accuracy
Accuracy

%% Saving User's Results
cd('../Tumor_Search_Times');
if isdir('Results')
    cd('Results');
elseif ~isdir('Results')
    mkdir('Results');
    cd('Results');
end

nameID = char(upper(subject_info(1))); % Take the initials (first cell in subject_info) and make it uppercase so our formatting is consistent. Also convert the cell to a character array (a string)
dirName = num2str(subjectNumber) + "_" + nameID; % Name the user's results directory with the format of "[subject number]-[initials]"

if ~isdir(dirName)
    mkdir(dirName);
end

cd(dirName);
number_of_trials = number_of_trials - 1; % First trial can't be affected by serial dependence
save('SubjectInfo.mat', 'subject_info');
save('Results.mat',  'reactionTimes', 'tumorClasses', 'tumorsShown', 'yesOrNo');

Screen('CloseAll');
cd('../../'); %Go back to original directory.
