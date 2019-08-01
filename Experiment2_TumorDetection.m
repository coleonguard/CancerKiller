Setting up
close all;
clear all;
%global delayTime; % Retrieving the global variable value from our app GUI

Obtaining User Input
Info = {'Initials', 'Full Name','Gender [1=Male, 2=Female, 3=Other]','Age','Ethnicity', 'Years of Experience'};
dlg_title = 'Subject Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);

existingData = load('subjectNumber.mat');
subjectNumber = existingData.subjectNumber + 1;
save('subjectNumber', 'subjectNumber');

number_of_trials = 10;
response = zeros(number_of_trials,1);%if the user is right or wrong

isserialdependence = zeros(1,number_of_trials);
actualaccuracy = zeros(1,number_of_trials);

whichone = zeros(1,number_of_trials);

Load Screens
Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0,[128 128 128]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

HideCursor();
window_w = rect(3); % defining size of screen
window_h = rect(4);

x_center = window_w/2;
y_center = window_h/2;

noisePatterns = cell(147, 1);

cd('shape_Stimuli');

showing random morph image behind noise
for f = 1:147
    Mask_Plain = imread([num2str(f) 'mask.JPG']); %Load black circle on white background.
    Mask_Plain = 255-Mask_Plain(:,:,1); %use first layer
    tmp_bmp = imread(['Morph' num2str(f) '.JPG']);
    tmp_bmp(:,:,4) = Mask_Plain;
    tid(f) = Screen('MakeTexture', window, uint8(tmp_bmp));
    
    greyorblack = round(rand(window_w, window_h)) * 255;
    for cols = 1:window_h
        for rows = 1:window_w
            if greyorblack(rows,cols) == 255 %white (light)
                greyorblack(rows,cols) = 72;
            elseif greyorblack(rows, cols) == 0 %black (dark)
                greyorblack(rows,cols) = 45;
            end
        end
    end
    
    noisePatterns{f} = greyorblack;
    
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, sprintf('%d%%',round(f*(100/147))), 120, y_center+412.9950); % Write text to confirm percentage complete
    
    Screen('DrawText', window, 'Hello! Welcome to the Tumor Detection Experiment.', x_center-238, y_center)
    Screen('DrawText', window, 'In the following screen, a random shape representing a tumor will or will not be displayed.', x_center-378, y_center + 25)
    Screen('DrawText', window, 'After the display time has elapsed, please click 1 if there was 2 if there was not a tumor present.', x_center-648, y_center + 50)
    Screen('Flip', window); % Display text -- loading stuff
end

HideCursor();

img_w = size(tmp_bmp, 2)/4; % width of pictures
img_h = size(tmp_bmp, 1)/4; % height of pictures
trial_num = 1;

shapethereornot = randi([1,2], 1, number_of_trials);

for trial_num = 1:number_of_trials
    
    random_location = [0,0]; %making a random location for the image to be displayed at
    random_location(1) = randi([ceil(img_w/2) floor(window_w-(img_w/2))]);
    random_location(2) = randi([ceil(img_h/2) floor(window_h-(img_h/2))]);
    shape_num = 147; % total number of stimuli
    
   
    randshape = randi(shape_num); % making sure the shape is different each time (random)
    % changing the colors of the noise to be closer to the background color of the image
    
    mask_mem = resizem(noisePatterns{trial_num}, [2 * rect(4), 2 * rect(3)]);
    for hi = 1:3
        background(:,:,hi) = mask_mem;
    end
    background(:,:,4) = ones(2 * rect(4),2 * rect(3)) * 200; %200 transparency
    
    mask_mem_Tex = Screen('MakeTexture', window, background);  % make the mask_memory texture
    if shapethereornot(1,trial_num) == 1
        Screen('DrawTexture', window, tid(randshape), [], ...
            [random_location(1)-img_w/2 random_location(2)-img_h/2 random_location(1)+img_w/2 random_location(2)+img_h/2]); % displaying images centered art the random point
    end
    Screen('DrawTexture',window, mask_mem_Tex); % draw the noise texture
    
    Screen('Flip', window);
    
    WaitSecs(.3);

showing three (A, B, and C) images and asking for the user to input which image the one he saw was closest to (using keys 1,2,3 respectively)
    DrawFormattedText(window,'Was the tumor present (1 for Yes, 2 for No)?','center',100,[0 0 0]);
    
    
    
    imageA_location = [window_w/3-img_w/2, y_center-img_h/2, window_w/3+img_w/2, y_center+img_h/2];
    imageB_location = [x_center-img_w/2, y_center-img_h/2, x_center+img_w/2, y_center+img_h/2];
    imageC_location = [2 * window_w/3-img_w/2, y_center-img_h/2, 2 * window_w/3+img_w/2, y_center+img_h/2];
        
    DrawFormattedText(window,'1',window_w/3,'center',[0 0 0]);
    DrawFormattedText(window,'OR','center','center',[0 0 0]);
    DrawFormattedText(window,'2',2 * window_w/3,'center',[0 0 0]);
    
    Screen('Flip', window);
    % all of ^ is getting the best place (monitor size independent) of where to
    % display the images and text and displaying them
    % getting keyboard input below
    
    tf = 0; %user clicks = 1 user didn't click = 0
    while tf == 0
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if keyIsDown == 1
            keypressed = KbName(keyCode);
            if strcmp(keypressed, '1!')
                tf = 1;
                whichone(1,trial_num) = 1;
            elseif strcmp(keypressed, '2@')
                tf = 1;
                whichone(1, trial_num) = 2;
            end
        end
    end    
end
for q=1:number_of_trials
    if whichone(1,q) == shapethereornot(1,q)
        actualaccuracy(1,q) = 1; %correct response = 1 in actualaccuracy array
        isserialdependence(1,q) = 0;
    else
        actualaccuracy(1,q) = 0;
        if whichone(1,q) == shapethereornot(1,q-1)
            isserialdependence(1,q) = 1; %there is serial dependence = 1 in the isserialdependence var
        else
            isserialdependence(1,q) = 0;
        end
    end
end


% Serial_Dependence = strcat(num2str(totalserials), '/', num2str(number_of_trials-1)); %shows the number w/ serial dependence
% Serial_Dependence
% Accuracy = strcat(num2str(actualaccuracy), '/', num2str(number_of_trials-1)); %shows accuracy
% Accuracy

Saving User's Results
cd('../');
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
save('Results.mat',  'isserialdependence', 'actualaccuracy', 'number_of_trials');

Screen('CloseAll');
cd('../'); %Go back to original directory.
cd('../');

