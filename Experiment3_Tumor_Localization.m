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

locations = zeros(number_of_trials, 2);

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
[window, rect] = Screen('OpenWindow', 0,[128 128 128]);
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
    Screen('DrawText', window, 'After the random shape has been displayed, please identify which of the 3 objects the original tumor looked most similar to.', x_center-648, y_center + 50)
    Screen('Flip', window); % Display text -- loading stuff
end


img_w = size(tmp_bmp, 2)/4; % width of pictures
img_h = size(tmp_bmp, 1)/4; % height of pictures
trial_num = 1;
difficulty = [5.0,trial_num]; %first index is the current difficulty level, the second index is the trial number
% goes up 1 every 3 right and goes down 1 every 3 wrong (user overall
% percentage)

for trial_num = 1:number_of_trials
    
    random_location = [0,0]; %making a random location for the image to be displayed at
    random_location(1) = randi([ceil(img_w/2) floor(window_w-(img_w/2))]);
    random_location(2) = randi([ceil(img_h/2) floor(window_h-(img_h/2))]);
    shape_num = 147; % total number of stimuli
    
    ifblank = randi(4);
    if ifblank == 4
        randshape = 0;
    else
        randshape = randi(shape_num); % making sure the shape is different each time (random)
        % changing the colors of the noise to be closer to the background color of the image
    end
    greyorblack = round(rand(window_w, window_h)) * 255;
    for cols = 1:window_h
        for rows = 1:window_w
            if greyorblack(rows,cols) == 255 %white (light)
                greyorblack(rows,cols) = 45+difficulty(1)*4;
            elseif greyorblack(rows, cols) == 0 %black (dark)
                greyorblack(rows,cols) = 45;
            end
        end
    end
    
    mask_mem = resizem(greyorblack, [ceil(difficulty(1)/2) * rect(4), ceil(difficulty(1)/2) * rect(3)]);
    for hi = 1:3
        background(:,:,hi) = mask_mem;
    end
    background(:,:,4) = ones(ceil(difficulty(1)/2) * rect(4),ceil(difficulty(1)/2) * rect(3)) * 200;
    
    mask_mem_Tex = Screen('MakeTexture', window, background);  % make the mask_memory texture
    if ifblank ~=4
        Screen('DrawTexture', window, tid(randshape), [], ...
            [random_location(1)-img_w/2 random_location(2)-img_h/2 random_location(1)+img_w/2 random_location(2)+img_h/2]); % displaying images centered art the random point
    end
    Screen('DrawTexture',window, mask_mem_Tex); % draw the noise texture
    
    Screen('Flip', window);
    
    %% Getting User Clicks
    clickedYet = false;
    while ~clickedYet
	[x, y, clicks] = GetMouse;
	
	if any(clicks)
		clickdYet = true;
	end;
		
	locations(trial_num, 1) = x;
	locations(trial_num, 2) = y;
    end
    
end

totalserials = 0;
for i = 1:number_of_trials
    
    if actualresponse(:,:,i) == comparativeincorrect %if the answer is not similar to the previous stimuli
        isserialdependence(1,i) = 0;
    elseif actualresponse(:,:,i) == ones(3,3)
        isserialdependence(1,i) = 0;
    else
        %the user answers matches the correct answer key
        if ((isequal(actualresponse(:,:,i), comparativediagonal1(:,:))) || (isequal(actualresponse(:,:,i), comparativediagonal2(:,:))) || (isequal(actualresponse(:,:,i), comparativediagonal3(:,:)))) %if the answer is correct
            isserialdependence(1,i) = 0;
        else %if the answer is similar and is incorrect
            isserialdependence(1,i) = 1;
        end
    end
    totalserials = totalserials + isserialdependence(1,i);
end
Serial_Dependence = strcat(num2str(totalserials), '/', num2str(number_of_trials-1)); %shows the number w/ serial dependence
Serial_Dependence
Accuracy = strcat(num2str(actualaccuracy), '/', num2str(number_of_trials-1)); %shows accuracy
Accuracy

%% Saving User's Results
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
save('Results.mat',  'totalserials', 'actualaccuracy', 'number_of_trials');

Screen('CloseAll');
cd('../'); %Go back to original directory.
cd('../');
