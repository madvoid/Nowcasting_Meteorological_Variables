%% WindU_Range2.m
% Nipun Gunawardena
% Produce the data for the "6 plots" for the Wind V Component for dates Jan.
% 27, 2017 - Feb. 1, 2017 (Range2) using KASCADE data. Data is plotted in separate file

clear all, close all, clc


%% Load Data
tic
load('../../../LEMS_Avg_Latest.mat');
addpath('../..');
numLems = numFiles;     % Change/add variable name in avg. code?


%% Prepare inputs and targets
startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 15;                              % Number of inputs
numTargets = 8;                             % Number of targets
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize
targetsTotal = zeros(numTargets, limLen);   % Targets initialize

targetCell = {'LEMS A', 'LEMS B', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS L'};

% I, J, K as inputs
inputsTotal(1,:) = lemsAvgData{09}.windU(startIdx:endIdx);   % I
inputsTotal(2,:) = lemsAvgData{10}.windU(startIdx:endIdx);   % J
inputsTotal(3,:) = lemsAvgData{11}.windU(startIdx:endIdx);   % K

inputsTotal(4,:) = lemsAvgData{09}.windV(startIdx:endIdx);   % I
inputsTotal(5,:) = lemsAvgData{10}.windV(startIdx:endIdx);   % J
inputsTotal(6,:) = lemsAvgData{11}.windV(startIdx:endIdx);   % K

inputsTotal(7,:) = lemsAvgData{09}.MLX_IR_C(startIdx:endIdx);   % I
inputsTotal(8,:) = lemsAvgData{10}.MLX_IR_C(startIdx:endIdx);   % J
inputsTotal(9,:) = lemsAvgData{11}.MLX_IR_C(startIdx:endIdx);   % K

inputsTotal(10,:) = lemsAvgData{09}.Pressure(startIdx:endIdx);   % I
inputsTotal(11,:) = lemsAvgData{10}.Pressure(startIdx:endIdx);   % J
inputsTotal(12,:) = lemsAvgData{11}.Pressure(startIdx:endIdx);   % K

inputsTotal(13,:) = lemsAvgData{09}.thetaV(startIdx:endIdx);   % I
inputsTotal(14,:) = lemsAvgData{10}.thetaV(startIdx:endIdx);   % J
inputsTotal(15,:) = lemsAvgData{11}.thetaV(startIdx:endIdx);   % K

% Rest as targets, excluding C
targetsTotal(1,:) = lemsAvgData{1}.windV(startIdx:endIdx);	 % A
targetsTotal(2,:) = lemsAvgData{2}.windV(startIdx:endIdx);	 % B 
targetsTotal(3,:) = lemsAvgData{4}.windV(startIdx:endIdx);	 % D
targetsTotal(4,:) = lemsAvgData{5}.windV(startIdx:endIdx);     % E
targetsTotal(5,:) = lemsAvgData{6}.windV(startIdx:endIdx);	 % F
targetsTotal(6,:) = lemsAvgData{7}.windV(startIdx:endIdx);	 % G
targetsTotal(7,:) = lemsAvgData{8}.windV(startIdx:endIdx);	 % H
targetsTotal(8,:) = lemsAvgData{12}.windV(startIdx:endIdx);    % L

% Resize dates
dates = dates(startIdx:endIdx);


%% Split into test and train

% % 1/15 - 1/20
% testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
% testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');

% 1/27 - 2/01 - See other file for these dates
testStart = find(dates > datenum([2017, 1, 26, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 2, 01, 00, 05, 00]), 1, 'last');

% Create test data
inputsTest = inputsTotal(:,testStart:testEnd);
targetsTest = targetsTotal(:,testStart:testEnd);
datesTest = dates(testStart:testEnd);
outputsTest = zeros(size(targetsTest));

% Create train data
inputsTrain = inputsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
targetsTrain = targetsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
datesTrain = dates([(1:testStart-1) (testEnd+1:limLen)]);


%% Plot inputs and outputs for comparison
figure()
hold all
plot(datesTrain, inputsTrain, '--', 'LineWidth', 2);
plot(datesTrain, targetsTrain);
dynamicDateTicks();
xlabel('Dates');
ylabel('\theta_v');
title('Input-Output Comparison')


%% Run ANN
% numHiddenCells = round(1.5*numInputs);
numHiddenCells = 14;
numRuns = 5;
rng('default');
for i = 1:numTargets
    fprintf('Predicting %s - %d/%d Targets\n', targetCell{i}, i, numTargets)
    for j = 1:numRuns
        fprintf('%d/%d ',j,numRuns);
        [net, tr] = HeterogeneityANN(inputsTrain, targetsTrain(i,:), 14, numHiddenCells);   % First 14 is random seed, not used in funciton as of 11/08/2018
        outputsTest(i,:) = outputsTest(i,:) + net(inputsTest);
    end
    fprintf('runs completed\n\n');
    outputsTest(i,:) = outputsTest(i,:) / numRuns;
end


%% Calculate Stats
mmOut = abs(max(outputsTest) - min(outputsTest));
stdOut = std(outputsTest);

mmTarg = abs(max(targetsTest) - min(targetsTest));
stdTarg = std(targetsTest);

mmTrain = abs(max(targetsTrain) - min(targetsTrain));
stdTrain = std(targetsTrain);


%% Save
save('1.27-2.01.mat', 'datesTest', 'targetsTest', 'outputsTest', 'mmOut', 'mmTarg', 'stdOut', 'stdTarg');


%% Notify end
toc
load chirp.mat
soundsc(y);