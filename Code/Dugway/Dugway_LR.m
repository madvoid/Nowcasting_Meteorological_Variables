%% Dugway_LR.m
% Nipun Gunawardena
% Test LinReg on Dugway data

clear all, close all, clc


%% Load Data
tic
load('PWIDS_5min_avg.mat');
pwid_xMean(1) = [];     % Remove first station for simplicity


% Create initial variables
rawDates = pwid_xMean(1).datenum;
numStations = length(pwid_xMean);
dataLen = length(pwid_xMean(1).datenum); 
pwidNames = cell(1, numStations);
for i = 1:numStations
    pwidNames{i} = pwid_xMean(i).name;
end

% Clean data
pwid_xMean(1).temp = pwid_xMean(1).temp - 273.15;   % Convert to C


%% Create train/test data

% 108, 33, 37, 72, 75, 78, 79, 90, 92, 93, 96   - Names
%  01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11   - Indices

startIdx = find(rawDates > datenum([2012, 10, 18, 0, 0, 0]), 1, 'first');  
endIdx = find(rawDates < datenum([2012, 10, 21, 0, 0, 0]), 1, 'last');
testIdx = startIdx:endIdx;
trainIdx = [(1:startIdx-1) (endIdx+1:dataLen)];

testLen = length(startIdx:endIdx);      % Length of test data
trainLen = length([(1:startIdx-1) (endIdx+1:dataLen)]); % Length of training data

targIdx = [1, 2, 3, 4, 5, 6, 9, 11];    % Station indices that will be targets
inIdx = [7, 8, 10];

numInStations = 3;
numVars = 4;    % Relative humidity, temperature, U, V
numTargets = numStations - numInStations;
numInputs = numInStations*numVars;

% Initialize arrays
inputsTest = zeros(numInputs, testLen);
inputsTrain = zeros(numInputs, trainLen);

targetsTest = zeros(numTargets, testLen);
targetsTrain = zeros(numTargets, trainLen);

outputsTest = zeros(size(targetsTest));
outputsTrain = zeros(size(targetsTrain));

datesTest = rawDates(testIdx);
datesTrain = rawDates([(1:startIdx-1) (endIdx+1:end)]);

targetCell = cell(1, numTargets);

% Fill inputs array
j = 1;
for i = inIdx
    inputsTest(j, :) = pwid_xMean(i).relHum(testIdx);
    inputsTest(j+1, :) = pwid_xMean(i).temp(testIdx);
    inputsTest(j+2, :) = pwid_xMean(i).wVec(testIdx,1)';
    inputsTest(j+3, :) = pwid_xMean(i).wVec(testIdx,2)';
    
    inputsTrain(j, :) = pwid_xMean(i).relHum(trainIdx);
    inputsTrain(j+1, :) = pwid_xMean(i).temp(trainIdx);
    inputsTrain(j+2, :) = pwid_xMean(i).wVec(trainIdx,1)';
    inputsTrain(j+3, :) = pwid_xMean(i).wVec(trainIdx,2)';
    
    j = j + numVars;
end

% Fill targets array
j = 1;
for i = targIdx
    targetsTest(j, :) = pwid_xMean(i).temp(testIdx);
    targetsTrain(j, :) = pwid_xMean(i).temp(trainIdx);
    targetCell{j} = pwid_xMean(i).name;
    j = j + 1;
end



%% Move from struct

% Clean raw data
% rawData(2,:) = rawData(2,:) - 273.15;   % Get to C
% rawData(3,:) = rawData(3,:) / 100;  % Get to millibar

% % Plot Raw
% figure()
% hold on
% plot(rawDates, rawData')
% dynamicDateTicks;
% xlabel('Time')
% title('Raw Data');

% Determine best test data
% nancount = sum(isnan(targetsTest));
% figure()
% hold on
% plot(rawDates, nancount);
% dynamicDateTicks;
% xlabel('Time')
% ylabel('NaN Count')
% title('NaN Count');

% Test data will be from October 18 2012 0:0:5 to October 20 2012 23:55:00
% because there are few NaNs during that time period



%% Plot inputs and outputs for comparison
figure()
subplot(2,1,1);
hold all
plot(datesTrain, inputsTrain, '--', 'LineWidth', 2);
plot(datesTrain, targetsTrain);
dynamicDateTicks();
xlabel('Dates');
title('Input-Output Comparison Train')
subplot(2,1,2);
hold all
plot(datesTest, inputsTest, '--', 'LineWidth', 2);
plot(datesTest, targetsTest);
dynamicDateTicks();
xlabel('Dates');
title('Input-Output Comparison Test')



%% Run LinReg

% Transpose for regression
inputsTrain = inputsTrain';
inputsTest = inputsTest';

targetsTrain = targetsTrain';
targetsTest = targetsTest';

outputsTest = outputsTest';

% Run Regression
for i = 1:numTargets
    fprintf('Predicting %s\n', targetCell{i});
    mdl = fitlm(inputsTrain, targetsTrain(:, i));
    outputsTest(:, i) = predict(mdl, inputsTest);
end

% Un-transpose to match neural network code
outputsTest = outputsTest';
targetsTest = targetsTest';


%% Calculate Stats
mmOut = abs(nanmax(outputsTest) - nanmin(outputsTest));
stdOut = nanstd(outputsTest);

mmTarg = abs(nanmax(targetsTest) - nanmin(targetsTest));
stdTarg = nanstd(targetsTest);

mmTrain = abs(nanmax(targetsTrain) - nanmin(targetsTrain));
stdTrain = nanstd(targetsTrain);


%% Save
save('DugwayANNOut.mat', 'datesTest', 'targetsTest', 'outputsTest', 'mmOut', 'mmTarg', 'stdOut', 'stdTarg');


%% Plot
figure()
hold on
plot(datesTest, mmOut, 'b:', 'LineWidth', 2);
plot(datesTest, mmTarg, 'r-');
plot(datesTest, stdOut, 'm:', 'LineWidth', 2);
plot(datesTest, stdTarg, 'k-');
legend('Min - Max output','Min - Max Target','StdDev Output','StdDev Target');
dynamicDateTicks(); 
xlabel('Date');
ylabel('Relative Humidity (%)');
title(sprintf('Test Data || MM RMSE = %f || STD RMSE = %f', rmse(mmTarg, mmOut), rmse(stdTarg, stdOut)));

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,3);
names = targetCell;
for i = 1:8
    h = subplot(2,4,i);
    hold on
    plot(targetsTest(i,:), outputsTest(i,:), 'o', 'MarkerSize', 2);
    p = polyfit(targetsTest(i,:), outputsTest(i,:), 1);
    pLine = polyval(p, [min(outputsTest(i,:)) max(outputsTest(i,:))]);
    plot([min(outputsTest(i,:)) max(outputsTest(i,:))], [pLine(1) pLine(2)], 'r-', 'LineWidth', 2);
    r2 = coefDeter(targetsTest(i,:), outputsTest(i,:));
    xlim = h.XLim;
    ylim = h.YLim;
    text(xlim(1)+0.5e1, ylim(2)-0.5e1, sprintf('R^2 = %f', r2));
    xlabel('Data');
    ylabel('ANN Output');
    title(names{i});
end
print('Dugway_MLR.eps', '-depsc');



%% Notify end
toc
load chirp.mat
soundsc(y);