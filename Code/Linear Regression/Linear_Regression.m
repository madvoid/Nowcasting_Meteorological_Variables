%% Linear_Regression.m
% Nipun Gunawardena
% Test linear regression on LEMS Data

clear all, close all, clc


%% Load Data
tic
load('../LEMS_Avg_Latest.mat');
numLems = numFiles;     % Change/add variable name in avg. code?

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));

% Significant p value
pSig = 0.05;


%% Prepare inputs and targets
startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 11;
numTargets = 1;
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize

% Inputs
for i = 1:12
    inputsTotal(i,:) = lemsAvgData{i}.SHT_Hum_Pct(startIdx:endIdx);
end

% Dates
dates = dates(startIdx:endIdx);


%% Split into test and train

% 1/15 - 1/20
testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');

% Create test data
inputsTest = inputsTotal(:,testStart:testEnd);
datesTest = dates(testStart:testEnd);

% Create train data
inputsTrain = inputsTotal(:,[(1:testStart-1) (testEnd+1:limLen)]);
datesTrain = dates([(1:testStart-1) (testEnd+1:limLen)]);

% Initialize outputs
outputsTest = zeros(size(inputsTest))';


%% Iterate through LEMS

for targetVar = 1:12
    % Training data
    inTrain = inputsTrain';
    taTrain = inTrain(:, targetVar);
    inTrain(:, targetVar) = [];
    
    % Test data
    inTest = inputsTest';
    taTest = inTest(:, targetVar);
    inTest(:, targetVar) = [];
    
    % Names
    inNames = lemsNames;
    taNames = inNames(targetVar);
    inNames(:, targetVar) = [];
    varNames = [inNames, taNames];
    
%     % Verification plots - Don't need to be run every time
%     figure()
%     hold all
%     plot(datesTrain(8700:8800), inTrain(8700:8800, :), '--', 'LineWidth', 2);
%     plot(datesTrain(8700:8800), taTrain(8700:8800), 'r-', 'LineWidth', 1);
%     dynamicDateTicks();
%     xlabel('Dates');
%     ylabel('Target Variable');
%     title(sprintf('Input-Output Comparison - Target %s', taNames{1}))
    
    % Train model
    mdl = fitlm(inTrain, taTrain, 'VarNames', varNames);
    
    % Test model
    outputsTest(:, targetVar) = predict(mdl, inTest);
    
    % Get stats
    coefNames = mdl.CoefficientNames;
    weights = mdl.Coefficients.Estimate;
    pVals = mdl.Coefficients.pValue;
    [~, wI] = sort(abs(weights), 'descend');
    pValsInsig = pVals > pSig;
    
    % Plot
    figure()
    subplot(1,2,1)
    hold all
    plot(datesTest, taTest, 'b--')
    plot(datesTest, outputsTest(:, targetVar), 'r-');
    dynamicDateTicks()
    xlabel('Date');
    ylabel('Target Variable');
    title(sprintf('Target-Output Comparison - %s', taNames{1}));
    legend('Target','Output');
    subplot(1,2,2)
    hold all
    plot(outputsTest(:, targetVar), taTest, 'o', 'MarkerSize', 5);
    xlabel('Prediction')
    ylabel('Data');
    title(sprintf('Target-Output 1-to-1 - %s', taNames{1}));
    grid on
    lline = lsline;
    hline = refline(1, 0);
    hline.Color = 'r';
    legend('Data', 'Fit', 'Ref.');
    
    % Print
    fprintf('Targeting %s\n\n', lemsNames{targetVar});
    fprintf('RMSE: %f\n', rmse(taTest, outputsTest(:, targetVar)));
    disp(mdl)
    disp(' ')
    fprintf('LEMS sorted by descending weight magnitude:\n');
    for i = 1:12
        fprintf('%s: %f\n', coefNames{wI(i)}, weights(wI(i)));
    end
    fprintf('\nLEMS with insignificant p-values:\n');
    coefNamesInsig = coefNames(pValsInsig);
    coefWeightsInsig = weights(pValsInsig);
    for i = 1:length(coefNamesInsig)
        fprintf('%s: %f\n', coefNamesInsig{i}, coefWeightsInsig(i));
    end
    fprintf('\n\n--------------------------------------------------------\n\n\n')
end