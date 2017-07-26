%% Hidden_Nodes.m
% Nipun Gunawardena
% Find good number of iterations for LEMS ANNs

clear all, close all, clc


%% Load Data
tic
load('../LEMS_Avg_Latest.mat');
numLems = numFiles;     % Change/add variable name in avg. code?

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));


%% Prepare inputs and targets
startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 11;
numTargets = 1;
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize
targetsTotal = zeros(numTargets, limLen);   % Targets initialize

% Inputs
j = 1;
for i = 1:12
    if i == 5
        continue
    end
    inputsTotal(j,:) = lemsAvgData{i}.windU(startIdx:endIdx);
    j = j + 1;
end

% Targets - LEMS E is target
targetsTotal(1,:) = lemsAvgData{5}.windU (startIdx:endIdx);

% Dates
dates = dates(startIdx:endIdx);


%% Split into test and train

% 1/15 - 1/20
testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');

% Create test data
inputsTest = inputsTotal(:,testStart:testEnd);
targetsTest = targetsTotal(:,testStart:testEnd);
datesTest = dates(testStart:testEnd);

% Create train data
inputsTrain = inputsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
targetsTrain = targetsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
datesTrain = dates([(1:testStart-1) (testEnd+1:limLen)]);


%% Plot inputs and outputs for comparison
figure()
hold all
plot(datesTrain, inputsTrain, '--', 'LineWidth', 2);
plot(datesTrain, targetsTrain, 'r-', 'LineWidth', 0.5);
dynamicDateTicks();
xlabel('Dates');
ylabel('Target Variable');
title('Input-Output Comparison')


%% Run

% % Multiple Runs - Hidden node check
% for i = 1:30
%     [net, ~] = ANN(inputsTrain, targetsTrain, i);
%     outputsTest = net(inputsTest);
%     fprintf('%i Nodes - RMSE = %f\n', i, rmse(targetsTest, outputsTest));
% end

% Single Run
i = 6;  % Good performance from 6
[net, ~] = ANN(inputsTrain, targetsTrain, i);
outputsTest = net(inputsTest);
fprintf('%i Hidden Nodes RMSE: %f\n', i, rmse(targetsTest, outputsTest));

figure()
hold all
plot(datesTest, targetsTest, '--')
plot(datesTest, outputsTest, '-r')
xlabel('Dates');
ylabel('Target Variable');
legend('Targets', 'Outputs');
dynamicDateTicks();