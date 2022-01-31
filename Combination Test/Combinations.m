%% Combinations.m
% Nipun Gunawardena
% Test ANN location sensitivity on LEMS Data, with different combinations
% of 3 LEMS

clear all, close all, clc


%% Load Data
tic
load('LEMS_Avg_Latest.mat');
numLems = numFiles;     % Change/add variable name in avg. code?

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));

% Significant p value
pSig = 0.05;

% Combinations
combi = nchoosek(1:12,3);

% Names
lemsNames = {'LEMS A', 'LEMS B', 'LEMS C', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS I', 'LEMS J', 'LEMS K', 'LEMS L'};

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));

% Stats
mmRmse = zeros(length(combi), 1);
stdRmse = mmRmse;
rSquared = zeros(length(combi), 9);     % Hardcode 2nd dim because lazy
netIters = rSquared;
netFail = cell(length(combi), 9);

failedRuns = cell(3,1);



%% Prepare ranges
% startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
startIdx = find(dates > datenum([2017, 01, 12, 16, 05, 0]), 1, 'first');
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');       % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
dates = dates(startIdx:endIdx);

% Test dates - 1/15 to 1/20
testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');
datesTest = dates(testStart:testEnd);

numInputs = 15;                             % Number of inputs
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize


%% Loop through combinations
for iter = 1:length(combi)
    fprintf('Predicting combination %i/%i\n', iter, length(combi));
    cCombi = combi(iter,:);
    
    % This way of creating inputs/targets isn't most efficient, but will do for now
    inputsTotal(1,:) = lemsAvgData{cCombi(1)}.windU(startIdx:endIdx);
    inputsTotal(2,:) = lemsAvgData{cCombi(2)}.windU(startIdx:endIdx);
    inputsTotal(3,:) = lemsAvgData{cCombi(3)}.windU(startIdx:endIdx);
    inputsTotal(4,:) = lemsAvgData{cCombi(1)}.windV(startIdx:endIdx);
    inputsTotal(5,:) = lemsAvgData{cCombi(2)}.windV(startIdx:endIdx);
    inputsTotal(6,:) = lemsAvgData{cCombi(3)}.windV(startIdx:endIdx);
    inputsTotal(7,:) = lemsAvgData{cCombi(1)}.MLX_IR_C(startIdx:endIdx);
    inputsTotal(8,:) = lemsAvgData{cCombi(2)}.MLX_IR_C(startIdx:endIdx);
    inputsTotal(9,:) = lemsAvgData{cCombi(3)}.MLX_IR_C(startIdx:endIdx);
    inputsTotal(10,:) = lemsAvgData{cCombi(1)}.Pressure(startIdx:endIdx);
    inputsTotal(11,:) = lemsAvgData{cCombi(2)}.Pressure(startIdx:endIdx);
    inputsTotal(12,:) = lemsAvgData{cCombi(3)}.Pressure(startIdx:endIdx);
    inputsTotal(13,:) = lemsAvgData{cCombi(1)}.thetaV(startIdx:endIdx);
    inputsTotal(14,:) = lemsAvgData{cCombi(2)}.thetaV(startIdx:endIdx);
    inputsTotal(15,:) = lemsAvgData{cCombi(3)}.thetaV(startIdx:endIdx);
    
    % Create target data
    nums = 1:12;
    for j = 1:length(cCombi)
        nums(nums == cCombi(j)) = [];
    end
    numTargets = length(nums);                  % Number of targets
    targetsTotal = zeros(numTargets, limLen);   % Targets initialize
    for j = 1:numTargets
        targetsTotal(j,:) = lemsAvgData{nums(j)}.thetaV(startIdx:endIdx);   % Change depending on desired target
    end
    
    % Create test data
    inputsTest = inputsTotal(:,testStart:testEnd);
    targetsTest = targetsTotal(:,testStart:testEnd);
    datesTest = dates(testStart:testEnd);
    outputsTest = zeros(size(targetsTest));
    
    % Create train data
    inputsTrain = inputsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
    targetsTrain = targetsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
    datesTrain = dates([(1:testStart-1) (testEnd+1:limLen)]);
    
    % Plot inputs and outputs for comparison - Optional
    %     figure()
    %     hold all
    %     plot(datesTrain, inputsTrain, '--', 'LineWidth', 2);
    %     plot(datesTrain, targetsTrain);
    %     dynamicDateTicks();
    %     xlabel('Dates');
    %     ylabel('Inputs and Targets');
    %     title('Input-Output Comparison')
    
    % Run MLR
    inputsTrain = inputsTrain';
    inputsTest = inputsTest';
    targetsTrain = targetsTrain';
    outputsTest = outputsTest';
    for j = 1:numTargets
        fprintf('\tTraining target %i/%i\n', j, numTargets);
        mdl = fitlm(inputsTrain, targetsTrain(:, j));
        outputsTest(:, j) = predict(mdl, inputsTest);
    end
    inputsTrain = inputsTrain';
    inputsTest = inputsTest';
    targetsTrain = targetsTrain';
    outputsTest = outputsTest';
    
    % Calculate Stats
    mmOut = abs(max(outputsTest) - min(outputsTest));
    stdOut = std(outputsTest);
    mmTarg = abs(max(targetsTest) - min(targetsTest));
    stdTarg = std(targetsTest);
    
    mmRmse(iter) = rmse(mmTarg, mmOut);
    stdRmse(iter) = rmse(stdTarg, stdOut);
    for j = 1:numTargets
        rSquared(iter, j) = coefDeter(targetsTest(j,:), outputsTest(j,:));
    end
%     if mmRmse(iter) > 10
%         failedRuns{1,iter} = iter;
%         failedRuns{2,iter} = targetsTest;
%         failedRuns{3,iter} = outputsTest;
%     end
    
end


%% Save
save('CombinationMLR.mat', 'combi', 'mmRmse', 'stdRmse', 'rSquared');


%% Finish
toc
load chirp.mat
soundsc(y);