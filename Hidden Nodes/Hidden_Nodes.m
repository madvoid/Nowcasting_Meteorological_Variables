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


%% Calculate specific humidity
eso = 6.11;         % hPa - Reference saturation vapor pressure
lv = 2.5e6;         % (J/kg) - Latent heat of vaporization of water
Rv = 461.5;         % (J*K)/kg - Gas constant for water vapor
T0 = 273.15;        % K - Reference temperature
for i = 1:numLems
    T = lemsAvgData{i}.SHT_Amb_C + 273.15;  % Convert to K
    P = lemsAvgData{i}.Pressure / 100;      % Convert to hPa
    RH = lemsAvgData{i}.SHT_Hum_Pct;        % percentage, no conversion
    es = eso * exp( (lv/Rv) * (1/T0 - 1./T) );  % Saturated vapor pressure
    e = (RH / 100) .* es;                   % Vapor pressure
    lemsAvgData{i}.specHum = 0.622 * (e./P);            % Specific humidity
    
    % Clean
    lemsAvgData{i}.specHum(lemsAvgData{i}.specHum > 0.2) = NaN;
end




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
    inputsTotal(j,:) = lemsAvgData{i}.windV(startIdx:endIdx);
    j = j + 1;
end

% Targets - LEMS E is target
targetsTotal(1,:) = lemsAvgData{5}.windV(startIdx:endIdx);

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

testLen = length(inputsTest);


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

% Multiple Runs - Hidden node check
numNodes = 30;
nodeRes = zeros(numNodes, 1);
numRuns = 5;
for i = 1:numNodes
    outputsTest = zeros(1, testLen);
    for j = 1:numRuns
        [net, tr] = ANN(inputsTrain, targetsTrain, i);
        outputsTest = outputsTest + net(inputsTest);
    end
    outputsTest = outputsTest / numRuns;
    fprintf('%i Nodes - RMSE = %f\n', i, rmse(targetsTest, outputsTest));
    nodeRes(i) = rmse(targetsTest, outputsTest);
end

figure()
hold on
plot(1:numNodes, nodeRes, 'o-')
xlabel('Number of Hidden Nodes')
ylabel('Root Mean Square Error');
title('Hidden Node Analysis');
print('ANN_Hidden_Nodes_windV.eps', '-depsc');
save('Hidden_Nodes_windV.mat', 'nodeRes');
toc


% %% Single Run
% i = 23;  % Good performance from 6
% [net, ~] = ANN(inputsTrain, targetsTrain, i);
% outputsTest = net(inputsTest);
% fprintf('%i Hidden Nodes RMSE: %f\n', i, rmse(targetsTest, outputsTest));
% 
% figure()
% hold all
% plot(datesTest, targetsTest, '--')
% plot(datesTest, outputsTest, '-r')
% xlabel('Dates');
% ylabel('Target Variable');
% legend('Targets', 'Outputs');
% dynamicDateTicks();