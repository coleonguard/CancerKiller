%% Setting up

close all;
clear all;

number_of_trials = 20;
response = zeros(number_of_trials,1);
s1 = [1,0,0;1,0,0;1,0,0]; % Matrix representing the first shape being shown
s2 = [0,1,0;0,1,0;0,1,0]; % Matrix representing the second shape being shown
s3 = [0,0,1;0,0,1;0,0,1]; % Matrix representing the third shape being shown
actualresponse = zeros(3,3,number_of_trials);
previousresponse = 0;
comparativeincorrect = zeros(3,3);
comparativediagonal1 = [1,0,0;0,0,0;0,0,0];
comparativediagonal2 = [0,0,0; 0,1,0;0,0,0];
comparativediagonal3 = [0,0,0;0,0,0;0,0,1];
isserialdependence = zeros(1,number_of_trials);
actualaccuracy = 0;
%% Load Screens

Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0,[128 128 128]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

HideCursor();
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
    Screen('DrawText', window, 'Loading...', x_center, y_center-25); % Write text to confirm loading of images
    Screen('DrawText', window, sprintf('%d%%',round(f*(100/147))), x_center, y_center+25); % Write text to confirm percentage complete
    Screen('Flip', window); % Display text -- loading stuff
end

HideCursor();

img_w = size(tmp_bmp, 2)/4; % width of pictures
img_h = size(tmp_bmp, 1)/4; % height of pictures


for trial_num = 1:number_of_trials
    
    random_location = [0,0]; %making a random location for the image to be displayed at
    random_location(1) = randi([ceil(img_w/2) floor(window_w-(img_w/2))]);
    random_location(2) = randi([ceil(img_h/2) floor(window_h-(img_h/2))]);
    shape_num = 147; % total number of stimuli
    
    randshape = randi(shape_num); % making sure the shape is different each time (random)
    
    greyorblack = round(rand(window_w, window_h)) * 255;
    for cols = 1:window_h
        for rows = 1:window_w
            if greyorblack(rows,cols) == 255
                greyorblack(rows,cols) = 75;
            elseif greyorblack(rows, cols) == 0
                greyorblack(rows,cols) = 45; % changing the colors of the noise to be closer to the background color of the image
            end
        end
    end
    mask_mem = resizem(greyorblack, [2 * rect(4), 2 * rect(3)]);
    for hi = 1:3
        background(:,:,hi) = mask_mem;
    end
    background(:,:,4) = ones(2*rect(4),2*rect(3)) * 200;
    
    mask_mem_Tex = Screen('MakeTexture', window, background);  % make the mask_memory texture

    Screen('DrawTexture', window, tid(randshape), [], ...
        [random_location(1)-img_w/2 random_location(2)-img_h/2 random_location(1)+img_w/2 random_location(2)+img_h/2]); % displaying images centered art the random point
        Screen('DrawTexture',window, mask_mem_Tex); % draw the noise texture

    Screen('Flip', window);
    
    WaitSecs(.2);
    %% showing three (A, B, and C) images and asking for the user to input which image the one he saw was closest to (using keys 1,2,3 respectively)
    
    DrawFormattedText(window,'Select which image the previously seen image is closest to?','center',100,[0 0 0]);
    imageA = imread('Morph49.JPG');
    imageB = imread('Morph98.JPG');
    imageC = imread('Morph147.JPG');
    makeA = Screen('MakeTexture', window, imageA);
    makeB = Screen('MakeTexture', window, imageB);
    makeC = Screen('MakeTexture', window, imageC);
    imageA_location = [window_w/3-img_w/2, y_center-img_h/2, window_w/3+img_w/2, y_center+img_h/2];
    imageB_location = [x_center-img_w/2, y_center-img_h/2, x_center+img_w/2, y_center+img_h/2];
    imageC_location = [2 * window_w/3-img_w/2, y_center-img_h/2, 2 * window_w/3+img_w/2, y_center+img_h/2];
    Screen('DrawTextures', window, makeA, [], imageA_location);
    Screen('DrawTextures', window, makeB, [], imageB_location);
    Screen('DrawTextures', window, makeC, [], imageC_location);
    DrawFormattedText(window,'1',window_w/3,((imageA_location(4)) + (.25 * img_h)),[0 0 0]);
    DrawFormattedText(window,'2','center',((imageB_location(4)) + (.25 * img_h)),[0 0 0]);
    DrawFormattedText(window,'3',2 * window_w/3,((imageC_location(4)) + (.25 * img_h)),[0 0 0]);
    Screen('Flip', window);
    % all of ^ is getting the best place (monitor size independent) of where to
    % display the images and text and displaying them
    % getting keyboard input below
    tf = 0;
    while tf == 0
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if keyIsDown == 1
            keypressed = KbName(keyCode);
            if strcmp(keypressed, '1!')
                tf = 1;
                whichone = 1;
            elseif strcmp(keypressed, '2@')
                tf = 1;
                whichone = 2;
            elseif strcmp(keypressed, '3#')
                tf = 1 ;
                whichone = 3;
            end
        end
    end

    if whichone == 1
        previousone = 1;
        if (randshape > 24.5 && randshape < 73.5)
            response(trial_num, 1) = 1; %1 entry in second column is for correct identification
            actualresponse(1,1,trial_num) = 1;
        elseif (randshape > 73.5 && randshape < 122.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(2,1,trial_num) = 1;
        elseif (randshape > 122.5 && randshape < 149) || (randshape > 0 && randshape < 24.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(3,1,trial_num) = 1;
        end
    elseif whichone == 2
        previousone = 2;
        if (randshape > 24.5 && randshape < 73.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(1,2,trial_num) = 1;
        elseif (randshape > 73.5 && randshape < 122.5)
            response(trial_num, 1) = 1; %1 entry in second column is for correct identification
            actualresponse(2,2,trial_num) = 1;
        elseif (randshape > 122.5 && randshape < 149) || (randshape > 0 && randshape < 24.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(3,2,trial_num) = 1;
        end
    elseif whichone == 3
        previousone = 3;
        if (randshape > 24.5 && randshape < 73.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(1,3,trial_num) = 1;
        elseif (randshape > 73.5 && randshape < 122.5)
            response(trial_num,1) = 0; %0 entry in second column for incorrect identification
            actualresponse(2,3,trial_num) = 1;
        elseif (randshape > 122.5 && randshape < 149) || (randshape > 0 && randshape < 24.5)
            response(trial_num, 1) = 1; %1 entry in second column is for correct identification
            actualresponse(3,3,trial_num) = 1;
        end
    end
    if previousresponse == 1
        actualresponse(:,:,trial_num) = actualresponse(:,:,trial_num).*s1;
    elseif previousresponse == 2
        actualresponse(:,:,trial_num) = actualresponse(:,:,trial_num).*s2;
    elseif previousresponse == 3
        actualresponse(:,:,trial_num) = actualresponse(:,:,trial_num).*s3;
    end     
    actualaccuracy = response(trial_num,1)+actualaccuracy;
end
totalserials = 0;
for i = 1:number_of_trials
    if actualresponse(:,:,i) == comparativeincorrect
        isserialdependence(1,i) = 0;
    else
        if ((isequal(actualresponse(:,:,i), comparativediagonal1(:,:))) || (isequal(actualresponse(:,:,i), comparativediagonal2(:,:))) || (isequal(actualresponse(:,:,i), comparativediagonal3(:,:))))
            isserialdependence(1,i) = 0;
        else
            isserialdependence(1,i) = 1;
        end
    end
    totalserials = totalserials + isserialdependence(1,i);
end
Serial_Dependence = strcat(num2str(totalserials), '/', num2str(number_of_trials));
Serial_Dependence
Accuracy = strcat(num2str(actualaccuracy), '/', num2str(number_of_trials));
Accuracy
Screen('CloseAll');
cd('../'); %Go back to original directory.