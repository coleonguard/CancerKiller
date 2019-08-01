%% Setting up
close all;
clear all;
%% Obtaining User Input

Info = {'Initials', 'Full Name','Gender [1=Male, 2=Female, 3=Other]','Age','Ethnicity', 'Years of Experience'};
dlg_title = 'Subject Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);

existingData = load('../subjectNumber.mat');
subjectNumber = existingData.subjectNumber + 1;
save('../subjectNumber.mat', 'subjectNumber');

number_of_trials = 100;
response = zeros(number_of_trials,1);%if the user is right or wrong

overtimeaccuracy = zeros(1, number_of_trials);

overtimeshapes = zeros(2,number_of_trials);

locations = zeros(number_of_trials, 2);

wasserialdependence = zeros(1,number_of_trials);
%% Load Screens

Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0,[128 128 128]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

window_w = rect(3); % defining size of screen
window_h = rect(4);

x_center = window_w/2;
y_center = window_h/2;

noisePatterns = cell(number_of_trials, 1);
mask_mem_Textures = cell(number_of_trials, 1);

cd('../shape_Stimuli');
%% showing random morph image behind noise

for f = 1:147
    Mask_Plain = imread([num2str(f) 'mask.JPG']); %Load black circle on white background.
    Mask_Plain = 255-Mask_Plain(:,:,1); %use first layer
    tmp_bmp = imread(['Morph' num2str(f) '.JPG']);
    tmp_bmp(:,:,4) = Mask_Plain;
    tid(f) = Screen('MakeTexture', window, uint8(tmp_bmp));
    
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, sprintf('%d%%',round(f*(100/147))), 120, y_center+412.9950); % Write text to confirm percentage complete
    
    Screen('DrawText', window, 'Hello! Welcome to the Tumor Localization Experiment.', x_center-238, y_center)
    Screen('DrawText', window, 'In the following screen, a random shape representing a tumor will be displayed.', x_center-378, y_center + 25)
    Screen('DrawText', window, 'After the random shape has been displayed, please identify the location at which it was shown.', x_center-648, y_center + 50)
    Screen('Flip', window); % Display text -- loading stuff
end
Screen('Flip', window);
%% Making noise patterns

background = zeros(2160, 3840, 4); % Initialize outside of loop
for f = 1 : number_of_trials
    
    Screen('DrawText', window, 'Generating stimuli...', x_center - 30, y_center);
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, sprintf('%d%%',round(f*(100/number_of_trials))), 120, y_center+412.9950); % Write text to confirm percentage complete
    Screen('Flip', window);
    
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
    
    
    
    noisePatterns{f} = greyorblack;
    
    mask_mem = resizem(noisePatterns{f}, [2 * rect(4), 2 * rect(3)]);
    for hi = 1:3
        background(:,:,hi) = mask_mem;
    end
    background(:,:,4) = ones(2 * rect(4),2 * rect(3)) * 200;
    
    mask_mem_Textures{f} = Screen('MakeTexture', window, background);  % make the mask_memory texture
    
end

Screen('Flip', window);
Screen('DrawText', window, 'Click to begin!', x_center - 35, y_center);
Screen('Flip', window);

clickedYet = false;
while ~clickedYet
    [x, y, clicks] = GetMouse;
    if any(clicks)
        clickedYet = true;
    end
end
%% Trials

img_w = size(tmp_bmp, 2)/4; % width of pictures
img_h = size(tmp_bmp, 1)/4; % height of pictures



for trial_num = 1:number_of_trials
    HideCursor();
    random_location = [0,0]; %making a random location for the image to be displayed at
    random_location(1) = randi([ceil(img_w/2) floor(window_w-(img_w/2))]);
    random_location(2) = randi([ceil(img_h/2) floor(window_h-(img_h/2))]);
    shape_num = 147; % total number of stimuli
    randshape = randi(shape_num); % making sure the shape is different each time (random)
    % changing the colors of the noise to be closer to the background color of the image
    
    
    Screen('DrawTexture', window, tid(randshape), [], ...
        [random_location(1)-img_w/2 random_location(2)-img_h/2 random_location(1)+img_w/2 random_location(2)+img_h/2]); % displaying images centered art the random point
    Screen('DrawTexture',window, mask_mem_Textures{trial_num}); % draw the noise texture
    
    Screen('Flip', window);
    
    WaitSecs(0.2);
    ShowCursor()
    Screen('DrawTexture',window, mask_mem_Textures{trial_num}); % draw the noise texture
    
    Screen('Flip', window);
%% Getting User Clicks

    clickedYet = false;
    while ~clickedYet
        [x, y, clicks] = GetMouse;
        
        if any(clicks)
            clickedYet = true;
        end
        
        locations(trial_num, 1) = x;
        locations(trial_num, 2) = y;
    end
    overtimeshapes(1,trial_num) = random_location(1);
    overtimeshapes(2,trial_num) = random_location(2);
end
for q = 1:number_of_trials
    if ((locations(q, 1) > overtimeshapes(1,q)-img_w/2) && (locations(q, 1) < overtimeshapes(1,q)+img_w/2)) && ((locations(q, 2) > overtimeshapes(2,q)-img_h/2) && (locations(q, 2) < overtimeshapes(2,q)+img_h/2))
        overtimeaccuracy(q) = 1; %1 for correct
        wasserialdependence(1,q) = 0;
    else
        overtimeaccuracy(q) = 0; %0 for incorrect
        %doing distance analysis to determine whether or not serial
        %dependence (and to what extent) was present -- wasserialdependence
        %will have 0 if no serial dependence and 1 if max serial dependence
        if q>=2
            X = [overtimeshapes(1,q-1),overtimeshapes(2,q-1);locations(q,1),locations(q,2)];
            a = pdist(X,'euclidean');
            Y = [overtimeshapes(1,q),overtimeshapes(2,q);overtimeshapes(1,q-1),overtimeshapes(2,q-1)];
            c = pdist(Y,'euclidean');
            if a<c
                wasserialdependence(1,q) = 1-(a/(c-((img_w/2+img_h/2)/2))); %normalization of the degree of serial dependence
            else
                wasserialdependence(1,q) = 0;
            end
        else
            wasserialdependence(1,q) = 0;
        end
    end
end
% Serial_Dependence = strcat(num2str(totalserials), '/', num2str(number_of_trials-1)); %shows the number w/ serial dependence
% Serial_Dependence
% Accuracy = strcat(num2str(actualaccuracy), '/', num2str(number_of_trials-1)); %shows accuracy
% Accuracy
%% Saving User's Results

cd('../Tumor_Localization');
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
save('Results.mat',  'wasserialdependence', 'overtimeaccuracy', 'number_of_trials');

Screen('CloseAll');
cd('../'); %Go back to original directory.
cd('../');