%% Virtual_Potential_Temperature_Range1.m
% Nipun Gunawardena
% Produce the data for the "6 plots" for Virtual Potential Temperature for dates Jan.
% 15-20, 2017 (Range1) using KASCADE data. Data is plotted in separate file

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
targetsTotal(1,:) = lemsAvgData{1}.thetaV(startIdx:endIdx);	 % A
targetsTotal(2,:) = lemsAvgData{2}.thetaV(startIdx:endIdx);	 % B 
targetsTotal(3,:) = lemsAvgData{4}.thetaV(startIdx:endIdx);	 % D
targetsTotal(4,:) = lemsAvgData{5}.thetaV(startIdx:endIdx);     % E
targetsTotal(5,:) = lemsAvgData{6}.thetaV(startIdx:endIdx);	 % F
targetsTotal(6,:) = lemsAvgData{7}.thetaV(startIdx:endIdx);	 % G
targetsTotal(7,:) = lemsAvgData{8}.thetaV(startIdx:endIdx);	 % H
targetsTotal(8,:) = lemsAvgData{12}.thetaV(startIdx:endIdx);    % L

% Resize dates
dates = dates(startIdx:endIdx);

% Clean
targetsTotal(targetsTotal > 350) = NaN;


%% Split into test and train

% 1/15 - 1/20
testStart1 = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd1 = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');

% % 1/27 - 2/01 
testStart2 = find(dates > datenum([2017, 1, 26, 23, 55, 00]), 1, 'first');
testEnd2 = find(dates < datenum([2017, 2, 01, 00, 05, 00]), 1, 'last');

% Create test data
inputsTest1 = inputsTotal(:,testStart1:testEnd1);
targetsTest1 = targetsTotal(:,testStart1:testEnd1);
datesTest1 = dates(testStart1:testEnd1);
outputsTest1 = zeros(size(targetsTest1));

inputsTest2 = inputsTotal(:,testStart2:testEnd2);
targetsTest2 = targetsTotal(:,testStart2:testEnd2);
datesTest2 = dates(testStart2:testEnd2);
outputsTest2 = zeros(size(targetsTest2));

% Create train data
inputsTrain = inputsTotal(:,[(1:testStart1-1) (testEnd1+1:limLen)]);
targetsTrain = targetsTotal(:,[(1:testStart1-1) (testEnd1+1:limLen)]);
datesTrain = dates([(1:testStart1-1) (testEnd1+1:limLen)]);

trs2 = find(datesTrain > datenum([2017, 1, 26, 23, 55, 00]), 1, 'first');
tre2 = find(datesTrain < datenum([2017, 2, 01, 00, 05, 00]), 1, 'last');

limLen2 = length(datesTrain);
inputsTrain = inputsTrain(:,[(1:trs2-1) (tre2+1:limLen2)]);
targetsTrain = targetsTrain(:,[(1:trs2-1) (tre2+1:limLen2)]);
datesTrain = dates([(1:trs2-1) (tre2+1:limLen2)]);


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
        outputsTest1(i,:) = outputsTest1(i,:) + net(inputsTest1);
        outputsTest2(i,:) = outputsTest2(i,:) + net(inputsTest2);
    end
    fprintf('runs completed\n\n');
    outputsTest1(i,:) = outputsTest1(i,:) / numRuns;
    outputsTest2(i,:) = outputsTest2(i,:) / numRuns;
end


%% Calculate Stats for Range 1
mmOut = abs(max(outputsTest1) - min(outputsTest1));
stdOut = std(outputsTest1);

mmTarg = abs(max(targetsTest1) - min(targetsTest1));
stdTarg = std(targetsTest1);

mmTrain = abs(max(targetsTrain) - min(targetsTrain));
stdTrain = std(targetsTrain);


%% Save
datesTest = datesTest1;
targetsTest = targetsTest1;
outputsTest = outputsTest1;
save('1.15-1.20.mat', 'datesTest', 'targetsTest', 'outputsTest', 'mmOut', 'mmTarg', 'stdOut', 'stdTarg');


%% Calculate Stats for Range 2
mmOut = abs(max(outputsTest2) - min(outputsTest2));
stdOut = std(outputsTest2);

mmTarg = abs(max(targetsTest2) - min(targetsTest2));
stdTarg = std(targetsTest2);

mmTrain = abs(max(targetsTrain) - min(targetsTrain));
stdTrain = std(targetsTrain);


%% Save
datesTest = datesTest2;
targetsTest = targetsTest2;
outputsTest = outputsTest2;
save('1.27-2.01.mat', 'datesTest', 'targetsTest', 'outputsTest', 'mmOut', 'mmTarg', 'stdOut', 'stdTarg');


%% Notify end
toc
load chirp.mat
soundsc(y);