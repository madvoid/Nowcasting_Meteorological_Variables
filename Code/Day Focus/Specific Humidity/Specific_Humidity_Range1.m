%% Specific_Humidity_Range1.m
% Nipun Gunawardena
% Produce the data for the "6 plots" for Specific Humidity for dates Jan.
% 15-20, 2017 (Range1) using KASCADE data. Data is plotted in separate file

clear all, close all, clc


%% Load Data
tic
load('../../LEMS_Avg_Latest.mat');
addpath('..');
numLems = numFiles;     % Change/add variable name in avg. code?


%% Calculate specific humidity
eso = 6.11;         % hPa - Reference saturation vapor pressure
lv = 2.5e6;         % (J/kg) - Latent heat of vaporization of water
Rv = 461.5;         % (J*K)/kg - Gas constant for water vapor
T0 = 273.15;        % K - Reference temperature
specHum = zeros(12,length(dates));
for i = 1:numLems
    T = lemsAvgData{i}.SHT_Amb_C + 273.15;  % Convert to K
    P = lemsAvgData{i}.Pressure / 100;      % Convert to hPa
    RH = lemsAvgData{i}.SHT_Hum_Pct;        % percentage, no conversion
    es = eso * exp( (lv/Rv) * (1/T0 - 1./T) );  % Saturated vapor pressure
    e = (RH / 100) .* es;                   % Vapor pressure
    specHum(i,:) = 0.622 * (e./P);            % Specific humidity
end

% Clean
specHum(specHum > 0.2) = NaN;


%% Prepare inputs and targets
startIdx = find(dates > datenum([2016, 12, 16, 0, 0, 0]), 1, 'first');  % Don't start at beginning, wait until sufficient installation. However, do not wait for C since not included
endIdx = find(dates < datenum([2017, 03, 15, 9, 0, 0]), 1, 'last');   % Stop before NaNs start

limLen = length(startIdx:endIdx);            % Length of limited data
numInputs = 15;                              % Number of inputs
numTargets = 8;                             % Number of targets
inputsTotal = zeros(numInputs, limLen);     % Inputs initialize
targetsTotal = zeros(numTargets, limLen);   % Targets initialize

targetCell = {'LEMS A', 'LEMS B', 'LEMS C', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS L'};

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

inputsTotal(13,:) = specHum(9, startIdx:endIdx);   % I
inputsTotal(14,:) = specHum(10, startIdx:endIdx);   % J
inputsTotal(15,:) = specHum(11, startIdx:endIdx);   % K

% Rest as targets, excluding C
targetsTotal(1,:) = specHum(1, startIdx:endIdx);	 % A
targetsTotal(2,:) = specHum(2, startIdx:endIdx);	 % B 
targetsTotal(3,:) = specHum(4, startIdx:endIdx);	 % D
targetsTotal(4,:) = specHum(5, startIdx:endIdx);     % E
targetsTotal(5,:) = specHum(6, startIdx:endIdx);	 % F
targetsTotal(6,:) = specHum(7, startIdx:endIdx);	 % G
targetsTotal(7,:) = specHum(8, startIdx:endIdx);	 % H
targetsTotal(8,:) = specHum(12, startIdx:endIdx);    % L

% Resize dates
dates = dates(startIdx:endIdx);


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
for i = 1:numTargets
    [net, tr] = HeterogeneityANN(inputsTrain, targetsTrain(i,:), 14, numHiddenCells);   % First 14 is random seed
    outputsTest(i,:) = net(inputsTest);
    fprintf('Predicting %s - %d/%d\n', targetCell{i}, i, numTargets)
end


%% Calculate Stats
mmOut = abs(max(outputsTest) - min(outputsTest));
stdOut = std(outputsTest);

mmTarg = abs(max(targetsTest) - min(targetsTest));
stdTarg = std(targetsTest);

mmTrain = abs(max(targetsTrain) - min(targetsTrain));
stdTrain = std(targetsTrain);


%% Save
save('1.15-1.20.mat', 'datesTest', 'targetsTest', 'outputsTest', 'mmOut', 'mmTarg', 'stdOut', 'stdTarg');


%% Notify end
toc
load chirp.mat
soundsc(y);