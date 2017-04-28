
%% Introduction 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is an example on how to:
% 1. Read the accelerometer data of a subject for an activity & position
% 2. Read the Ground Truth Heel-Strike and Toe-Off gait events for the same
% 3. Plot all the signals

% Written by Siddhartha Khandelwal, Intelligent Systems Laboratory, 
% Halmstad University, Sweden
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the acceleration and timing files

clear all
close all

% Path to load .mat files from this folder
loadFolderName = 'Subject Data_mat format\';

% Load the Indoor and Outdoor Activity Experiment Timings .mat file
load('Activity Timings\Indoor Experiment Timings.mat')
load('Activity Timings\Outdoor Experiment Timings.mat')
% Load the Ground Truth Structure
load GroundTruth.mat
%% Activity Labels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% treadWalk       = indoorTime(:,1:2);
% treadIncline    = indoorTime(:,4:5);
% treadWalknRun   = indoorTime(:,1:3);
% indoorWalk      = indoorTime(:,6:7);
% indoorRun       = indoorTime(:,6:8);    
% outdoorWalk     = outdoorTime(:,1:2);
% outdoorWalknRun = outdoorTime(:,1:3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define Activity Labels
indoorLabel = {'treadWalk';'treadIncline';'treadWalknRun';'indoorWalk';'indoorWalknRun'};
outdoorLabel = {'outdoorWalk';'outdoorWalknRun'};

% Column numbers to extract desired activity data from Subject acceleration files
indoorIdx = [1,2; 4,5; 1,3; 6,7; 6,8];
outdoorIdx = [1,2; 1,3];


%% Choose a Subject Number

clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject numbers 1 to 11 are involved in Indoor Experiments
% Subject numbers 12 to 20 are involved in Outdoor Experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Subject nos. 1 to 11 are involved in Indoor Experiments\nSubject nos. 12 to 20 are involved in Outdoor Experiments\n');

subNo = input('Enter a Subject No. and press Enter:  ');
if subNo < 0 || subNo > 20
    disp('Error: This is not a valid Subject No.'); 
    return;
end

%% Choose an indoor or outdoor activity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There are five Indoor Activity labels: 
% actIndex = 1 -> treadWalk
% actIndex = 2 -> treadIncline
% actIndex = 3 -> treadWalknRun
% actIndex = 4 -> indoorWalk 
% actIndex = 5 -> indoorWalknRun

% There are two Outdoor Activity labels: 
% actIndex = 1 -> outdoorWalk
% actIndex = 2 -> outdoorWalknRun
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if subNo > 0 && subNo <= 11 
    myString = ['\nChoose an indoor activity index (actIndex) from 1 to 5'...
    '\nactIndex: 1 -> treadWalk'...
    '\nactIndex: 2 -> treadIncline'...
    '\nactIndex: 3 -> treadWalknRun'...
    '\nactIndex: 4 -> indoorWalk'... 
    '\nactIndex: 5 -> indoorWalknRun\n'];
    fprintf(myString);
    actIndex = input('Enter an activity index from 1 to 5 and press Enter:  ');
    
    if actIndex < 1 || actIndex > 5
        disp('Error: This is not a valid activity index'); 
        return;
    end

elseif subNo > 11 && subNo <= 20 
    myString = ['\nChoose an outdoor activity index (actIndex) from 1 to 2'...
    '\nactIndex: 1 -> outdoorWalk'...
    '\nactIndex: 2 -> outdoorWalknRun\n'];
    fprintf(myString);
    actIndex = input('Enter an activity index from 1 to 2 and press Enter:  ');
    
    if actIndex < 1 || actIndex > 2
        disp('Error: This is not a valid activity index'); 
        return;
    end

end

%% Choose a accelerometer position 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There are four accelerometer positions (accPos) to choose from:
% accPos = 1 -> Left Foot
% accPos = 2 -> Right Foot
% accPos = 3 -> Waist
% accPos = 4 -> Wrist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
posVal = {'LF','RF','Waist','Wrist'};
myString = ['\nChoose the accelerometer position(accPos): '...
    '\naccPos: 1 -> Left Foot'...
    '\naccPos: 2 -> Right Foot'...
    '\naccPos: 3 -> Waist'...
    '\naccPos: 4 -> Wrist\n'];
fprintf(myString);
accPos = input('Enter a accPos value from 1 to 4 and press Enter:  ');

if accPos < 1 || accPos > 4
    disp('Error: This is not a valid position value');
    return;
end

%% Load the mat file for a given Subject, Activity Index & Acc position

% Generate the file name based on the input choices 
loadFileName = strcat('Sub',num2str(subNo),'_',posVal{accPos});
% Load the .mat file using the generated filename
dataLF = load([loadFolderName loadFileName '.mat']); 

% Extract the timings of the chosen activity from the Indoor or Outdoor Timings matrix
if subNo > 0 && subNo <= 11 
    sigIdx = [indoorTime(subNo,indoorIdx(actIndex,1)), indoorTime(subNo,indoorIdx(actIndex,2))];
else if subNo > 11 && subNo <= 20 
        sigIdx = [outdoorTime(subNo-11,outdoorIdx(actIndex,1)), outdoorTime(subNo-11,outdoorIdx(actIndex,2))];
    end
end

% The X, Y and Z-axis acceleration signals
sig_accX = dataLF.accX(sigIdx(1):sigIdx(2));
sig_accY = dataLF.accY(sigIdx(1):sigIdx(2));
sig_accZ = dataLF.accZ(sigIdx(1):sigIdx(2));

%% Load the Ground Truth gait events

if accPos == 1 || accPos == 2
    if subNo > 0 && subNo <= 11 
        GTData = GroundTruth(subNo).(char(indoorLabel(actIndex)));
    else if subNo > 11 && subNo <= 20
            GTData = GroundTruth(subNo-11).(char(outdoorLabel(actIndex)));
        end
    end
 
end

%% Plot the signals

figure; 
plot(sig_accX); hold on; 
plot(sig_accY);
plot(sig_accZ);
% plot(sqrt(sigLF_accX.^2+sigLF_accY.^2+sigLF_accZ.^2));
ylabel('Acceleration');
xlabel('Time [in Samples]');
if accPos == 1
    plot(GTData.LF_HS,40.*ones(numel(GTData.LF_HS),1),'ks');
    plot(GTData.LF_TO,40.*ones(numel(GTData.LF_TO),1),'ko');
    legend('accX','accY','accZ','HS','TO');
    title(strcat('Sub',num2str(subNo),'--',posVal{accPos}))
else if accPos == 2
    plot(GTData.RF_HS,40.*ones(numel(GTData.RF_HS),1),'ks');
    plot(GTData.RF_TO,40.*ones(numel(GTData.RF_TO),1),'ko');
    legend('accX','accY','accZ','HS','TO');
    title(strcat('Sub',num2str(subNo),'--',posVal{accPos}))
    else if accPos > 2
        legend('accX','accY','accZ');
        end
    end
end
        






























    
















