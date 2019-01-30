%% LassoReg.m
% Nipun Gunawardena
% Do Lasso regression based on results from LinReg_Location.m

% See
% https://www.mathworks.com/help/econ/examples/time-series-regression-v-predictor-selection.html#zmw57dd0e3514
% for more

clear all, close all, clc


%% Load Data
load('../../LEMS_Avg_Latest.mat');
numLems = numFiles;     % Change/add variable name in avg. code?

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));

% Significant p value
pSig = 0.05;


%% Prepare inputs and targets
% startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
startIdx = find(dates > datenum([2017, 01, 12, 16, 05, 0]), 1, 'first');
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 11;
numTargets = 1;
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize

% Inputs
for i = 1:12
    inputsTotal(i,:) = lemsAvgData{i}.windU(startIdx:endIdx);
end

% Dates
dates = dates(startIdx:endIdx);


%% Split into test and train

targetLemsIdx = 9;  % 9 is LEMSI
inputLemsIdx = [1:targetLemsIdx-1, targetLemsIdx+1:numLems];

% 1/15 - 1/20
testStart = find(dates > datenum([2017, 1, 14, 23, 55, 00]), 1, 'first');
testEnd = find(dates < datenum([2017, 1, 20, 00, 05, 00]), 1, 'last');
trainPeriodIdx = [(1:testStart-1) (testEnd+1:limLen)];

% Create test data
inputsTest = inputsTotal(inputLemsIdx, testStart:testEnd)';
targetsTest = inputsTotal(targetLemsIdx, testStart:testEnd)';
datesTest = dates(testStart:testEnd)';

% Create train data
inputsTrain = inputsTotal(inputLemsIdx, trainPeriodIdx)';
targetsTrain = inputsTotal(targetLemsIdx, trainPeriodIdx)';
datesTrain = dates(trainPeriodIdx);

% Get names
inNames = lemsNames(inputLemsIdx);
taNames = lemsNames(targetLemsIdx);
varNames = [inNames, taNames];      % According to convention, target is last name


%% Plot inputs/targets to ensure separate
figure('units','normalized','outerposition',[0 0 1 1])
hold all
plot(datesTrain(8700:8800), inputsTrain(8700:8800, :), '--', 'LineWidth', 2);
plot(datesTrain(8700:8800), targetsTrain(8700:8800), 'r-', 'LineWidth', 1);
dynamicDateTicks();
xlabel('Dates');
ylabel('Target Variable');
title(sprintf('Input-Output Comparison - Target %s', taNames{1}))


%% Run standard linear regression for comparison
% Train model
mdl = fitlm(inputsTrain, targetsTrain, 'VarNames', varNames);

% Test model
outputsTest = predict(mdl, inputsTest);

% Get stats
coefNames = mdl.CoefficientNames;
weights = mdl.Coefficients.Estimate;
pVals = mdl.Coefficients.pValue;
[~, wI] = sort(abs(weights), 'descend');
pValsInsig = pVals > pSig;
R0 = corrcoef(inputsTrain, 'rows', 'complete');  % See https://www.mathworks.com/help/econ/examples/time-series-regression-ii-collinearity-and-estimator-variance.html for more info
VIF = diag(inv(R0));

% Plot
figure('units','normalized','outerposition',[0 0 1 1])
subplot(1,2,1)
hold all
plot(datesTest, targetsTest, 'b--')
plot(datesTest, outputsTest, 'r-');
dynamicDateTicks()
xlabel('Date');
ylabel('Target Variable');
title(sprintf('Target-Output Comparison - %s Standard LinReg', taNames{1}));
legend('Target','Output');
subplot(1,2,2)
hold all
plot(outputsTest, targetsTest, 'o', 'MarkerSize', 5);
xlabel('Prediction')
ylabel('Data');
title(sprintf('Target-Output 1-to-1 - %s Standard LinReg', taNames{1}));
grid on
lline = lsline;
hline = refline(1, 0);
hline.Color = 'r';
legend('Data', 'Fit', 'Ref.');

% Print
fprintf('**** Regular Regression *************************************\n');
fprintf('Targeting %s\n\n', taNames{1});
fprintf('RMSE: %f\n', rmse(targetsTest, outputsTest));
disp(mdl)
disp(' ')
fprintf('LEMS sorted by descending weight magnitude:\n');
for i = 1:length(wI)
    fprintf('%s: %f\n', coefNames{wI(i)}, weights(wI(i)));
end
fprintf('\nLEMS with insignificant p-values:\n');
coefNamesInsig = coefNames(pValsInsig);
coefWeightsInsig = weights(pValsInsig);
for i = 1:length(coefNamesInsig)
    fprintf('%s: %f\n', coefNamesInsig{i}, coefWeightsInsig(i));
end
fprintf('\nVariance Inflation Factors:\n');
for i = 1:length(VIF)
    fprintf('%s: %f\n', coefNames{i+1}, VIF(i));
end
fprintf('\n\n\n')


%% Lasso Regression
fprintf('**** Lasso Regression ***************************************\n');
[B, FitInfo] = lasso(inputsTrain, targetsTrain, 'CV', 10, 'PredictorNames', inNames);

% Plot
figure('units','normalized','outerposition',[0 0 1 1])
ax1 = subplot(2,1,1);
lassoPlot(B, FitInfo, 'Parent', ax1, 'PlotType', 'Lambda', 'XScale', 'log');
ax2 = subplot(2,1,2);
lassoPlot(B, FitInfo, 'Parent', ax2, 'PlotType', 'CV')

% Get models
minMSEModel = FitInfo.PredictorNames(B(:,FitInfo.IndexMinMSE)~=0);
sparseModel = FitInfo.PredictorNames(B(:,FitInfo.Index1SE)~=0);

% Print
fprintf('Minimum MSE Lasso Model || %d Predictors\n', length(minMSEModel));
for i = 1:length(minMSEModel)
    fprintf('%s\n', minMSEModel{i})
end

fprintf('\nSparse Lasso Model || %d Predictors\n', length(sparseModel));
for i = 1:length(sparseModel)
    fprintf('%s\n', sparseModel{i})
end
fprintf('\n\n\n')


%% Test sparse model

% Get good predictors
goodPred = (B(:,FitInfo.Index1SE)~=0)';
inputsTrainLim = inputsTrain(:, goodPred);
inputsTestLim = inputsTest(:, goodPred);

% Train model
mdl = fitlm(inputsTrainLim, targetsTrain, 'VarNames', [sparseModel taNames]);

% Test model
outputsTestLim = predict(mdl, inputsTestLim);

% Get stats
coefNames = mdl.CoefficientNames;
weights = mdl.Coefficients.Estimate;
pVals = mdl.Coefficients.pValue;
[~, wI] = sort(abs(weights), 'descend');
pValsInsig = pVals > pSig;
R0 = corrcoef(inputsTrainLim, 'rows', 'complete');  % See https://www.mathworks.com/help/econ/examples/time-series-regression-ii-collinearity-and-estimator-variance.html for more info
VIF = diag(inv(R0));

% Plot
figure('units','normalized','outerposition',[0 0 1 1])
subplot(1,2,1)
hold all
plot(datesTest, targetsTest, 'b--')
plot(datesTest, outputsTestLim, 'r-');
dynamicDateTicks()
xlabel('Date');
ylabel('Target Variable');
title(sprintf('Target-Output Comparison - %s Sparse Model', taNames{1}));
legend('Target','Output');
subplot(1,2,2)
hold all
plot(outputsTestLim, targetsTest, 'o', 'MarkerSize', 5);
xlabel('Prediction')
ylabel('Data');
title(sprintf('Target-Output 1-to-1 - %s Sparse Model', taNames{1}));
grid on
lline = lsline;
hline = refline(1, 0);
hline.Color = 'r';
legend('Data', 'Fit', 'Ref.');

% Plot Regular-Sparse Model difference
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1)
hold all
plot(datesTest, outputsTest, 'r-');
plot(datesTest, outputsTestLim, 'b-.');
dynamicDateTicks()
xlabel('Date');
ylabel('Target Variable');
title(sprintf('Regular-Sparse Model Comparison - %s', taNames{1}))
legend('Regular', 'Sparse');
subplot(2,1,2)
hold all
plot(datesTest, outputsTest-outputsTestLim);
dynamicDateTicks()
xlabel('Date')
ylabel('Target Difference')
title(sprintf('Regular - Sparse Difference - %s', taNames{1}))



fprintf('**** Sparse Model Regression ********************************\n');
fprintf('Still targeting %s\n\n', taNames{1});
fprintf('RMSE: %f\n', rmse(targetsTest, outputsTestLim));
disp(mdl)
disp(' ')
fprintf('LEMS sorted by descending weight magnitude:\n');
for i = 1:length(wI)
    fprintf('%s: %f\n', coefNames{wI(i)}, weights(wI(i)));
end
fprintf('\nVariance Inflation Factors:\n');
for i = 1:length(VIF)
    fprintf('%s: %f\n', coefNames{i+1}, VIF(i));
end
fprintf('\n\n\n')


%% Plot residuals
% figure()
% hold on
% plot(outputsTestLim, targetsTest - outputsTestLim);
% xlabel('Predicted')