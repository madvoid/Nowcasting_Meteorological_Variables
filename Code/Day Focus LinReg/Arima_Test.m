%% Arima_Test.m
% Nipun Gunawardena
% Playground for linear regression on wind data with ARIMA

clear all, close all, clc


%% Load Data
load('../LEMS_Avg_Latest.mat');
numLems = numFiles;     % Change/add variable name in avg. code?

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));


%% Prepare inputs and targets
startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 15;                              % Number of inputs
numTargets = 8;                             % Number of targets
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize
targetsTotal = zeros(numTargets, limLen);   % Targets initialize

targetCell = {'LEMS A', 'LEMS B', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS L'};
inputCell = {'WindU_I', 'WindU_J', 'WindU_K', 'WindV_I', 'WindV_J', 'WindV_K', 'MLX_I', 'MLX_J', 'MLX_K', 'BMP_I', 'BMP_J', 'BMP_K', 'thetaV_I', 'thetaV_J', 'thetaV_K'};

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
targetsTotal(1,:) = lemsAvgData{1}.windU(startIdx:endIdx);	 % A
targetsTotal(2,:) = lemsAvgData{2}.windU(startIdx:endIdx);	 % B 
targetsTotal(3,:) = lemsAvgData{4}.windU(startIdx:endIdx);	 % D
targetsTotal(4,:) = lemsAvgData{5}.windU(startIdx:endIdx);     % E
targetsTotal(5,:) = lemsAvgData{6}.windU(startIdx:endIdx);	 % F
targetsTotal(6,:) = lemsAvgData{7}.windU(startIdx:endIdx);	 % G
targetsTotal(7,:) = lemsAvgData{8}.windU(startIdx:endIdx);	 % H
targetsTotal(8,:) = lemsAvgData{12}.windU(startIdx:endIdx);    % L

% Resize dates
dates = dates(startIdx:endIdx);

% Focus of this run
focusLems = 1;  



%% Split into test and train

% 1/15 - 1/20
testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');

% % 1/27 - 2/01 - See other file for these dates
% testStart = find(dates > datenum([2017, 1, 26, 23, 55, 00]), 1, 'first');
% testEnd = find(dates < datenum([2017, 2, 01, 00, 05, 00]), 1, 'last');

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
% figure()
% hold all
% plot(datesTrain, inputsTrain, '--', 'LineWidth', 2);
% plot(datesTrain, targetsTrain);
% dynamicDateTicks();
% xlabel('Dates');
% ylabel('\theta_v');
% title('Input-Output Comparison')


%% Transpose for regression
inputsTrain = inputsTrain';
inputsTest = inputsTest';

targetsTrain = targetsTrain';
targetsTest = targetsTest';

outputsTest = outputsTest';


%% Run regression
Mdl = regARIMA('ARLags',10);
EstMdl = estimate(Mdl, targetsTrain(:, focusLems), 'X', inputsTrain, 'Display', 'params');
% [Y, E] = simulate(Mdl, 1442, 'X', inputsTest);