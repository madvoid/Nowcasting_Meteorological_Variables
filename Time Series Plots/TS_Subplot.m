%% TS_Subplot.m
% Nipun Gunawardena
% Plot time series in accordance with new version of paper FOR NEURAL
% NETWORK

clear all, close all, clc


%% Setup directories and variables
homeDir = pwd;
dirs = {'ANN/Specific Humidity','ANN/Virtual Potential Temperature','ANN/Wind U Component','ANN/Wind V Component'};
ylabs = {{'Specific','Humidity'}, {'Virtual Potential','Temperature (K)'}, 'U (m/s)', 'V (m/s)'};


%% Plot 1.15-1.20 dates
fig1 = figure();
set(fig1, 'Units', 'normalized', 'Position', [0,0,1,1]);

for i = 1:length(dirs)
    % Load Data
    cd(dirs{i});
    load('1.15-1.20.mat');
    
    usrStartDate = datenum([2017, 01, 17, 0, 0, 0]);
    usrEndDate = datenum([2017, 01, 19, 0, 0, 0]);
    startIndex = find(datesTest <= usrStartDate, 1, 'last');
    endIndex = find(datesTest >= usrEndDate, 1, 'first');
    numPoints = length(startIndex:endIndex);
    datesLim = datesTest(startIndex:endIndex);
    limIdx = startIndex:endIndex;
    
    % Plot
    subplot(4,2,i*2-1);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesLim, targetsTest(1,limIdx), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesLim, targetsTest(4,limIdx), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesLim, targetsTest(5,limIdx), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesLim, outputsTest(1,limIdx), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesLim, outputsTest(4,limIdx), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesLim, outputsTest(5,limIdx), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
%     if i == 1
%         legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A ANN','LEMS E ANN','LEMS F ANN');
%     end
%     
    % Remove first date because it's messy
    ax = gca; 
    xTickLabels = get(ax, 'XTickLabel');
    xTickLabels{1} = '';   % Needs to exist but make empty
    set(ax, 'XTickLabel', xTickLabels);
    
    cd('../..')
    
end


cd(homeDir);
dirs = {'MLR/Specific Humidity','MLR/Virtual Potential Temperature','MLR/Wind U Component','MLR/Wind V Component'};
for i = 1:length(dirs)
    % Load Data
    cd(dirs{i});
    load('1.15-1.20.mat');
    
    % Plot
    subplot(4,2,i*2);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesLim, targetsTest(1,limIdx), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesLim, targetsTest(4,limIdx), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesLim, targetsTest(5,limIdx), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesLim, outputsTest(1,limIdx), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesLim, outputsTest(4,limIdx), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesLim, outputsTest(5,limIdx), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
%     if i == 1
%         legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A Prediction','LEMS E Prediction','LEMS F Prediction');
%     end
    
    % Remove first date because it's messy
    ax = gca; 
    xTickLabels = get(ax, 'XTickLabel');
    xTickLabels{1} = '';   % Needs to exist but make empty
    set(ax, 'XTickLabel', xTickLabels);
    
    cd('../..')
    
end



print('TS_Combined_1-17', '-depsc');




%% Plot 1.27 - 2.01 dates
dirs = {'ANN/Specific Humidity','ANN/Virtual Potential Temperature','ANN/Wind U Component','ANN/Wind V Component'};
fig2 = figure();
set(fig2, 'Units', 'normalized', 'Position', [0,0,1,1]);
r2Arr = zeros(4, 8);
statsArrRmse = zeros(4, 2);
statsArrNrmse = zeros(4, 2);
rmseArr = zeros(4, 8);
nrmseArr = zeros(4, 8);
meanBiasArr = zeros(4, 8);

for i = 1:length(dirs)
    % Load Data
    cd(dirs{i});
    load('1.27-2.01.mat');
    
    usrStartDate = datenum([2017, 01, 27, 0, 0, 0]);
    usrEndDate = datenum([2017, 01, 29, 0, 0, 0]);
    startIndex = find(datesTest <= usrStartDate, 1, 'last');
    endIndex = find(datesTest >= usrEndDate, 1, 'first');
    numPoints = length(startIndex:endIndex);
    datesLim = datesTest(startIndex:endIndex);
    limIdx = startIndex:endIndex;
    
    % Plot
    subplot(4,2,i*2-1);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesLim, targetsTest(1,limIdx), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesLim, targetsTest(4,limIdx), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesLim, targetsTest(5,limIdx), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesLim, outputsTest(1,limIdx), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesLim, outputsTest(4,limIdx), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesLim, outputsTest(5,limIdx), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
%     if i == 1
%         legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A ANN','LEMS E ANN','LEMS F ANN');
%     end
        
    for j = 1:8
        r2Arr(i, j) = coefDeter(targetsTest(j,:), outputsTest(j,:));
        rmseArr(i, j) = rmse(targetsTest(j,:), outputsTest(j,:));
        nrmseArr(i, j) = rmseArr(i, j) / range(targetsTest(j,:));
        meanBiasArr(i, j) = nanmean(outputsTest(j,:)) - nanmean(targetsTest(j,:));
    end
    statsArrRmse(i, 1) = rmse(mmTarg, mmOut);
    statsArrRmse(i, 2) = rmse(stdTarg, stdOut);
    statsArrNrmse(i, 1) = statsArrRmse(i, 1) / range(mmTarg);
    statsArrNrmse(i, 2) = statsArrRmse(i, 2) / range(stdTarg);
    
    % Remove first date because it's messy
    ax = gca; 
    xTickLabels = get(ax, 'XTickLabel');
    xTickLabels{1} = '';   % Needs to exist but make empty
    set(ax, 'XTickLabel', xTickLabels);
    
    cd('../..')
    
end

cd(homeDir);
dirs = {'MLR/Specific Humidity','MLR/Virtual Potential Temperature','MLR/Wind U Component','MLR/Wind V Component'};

for i = 1:length(dirs)
    % Load Data
    cd(dirs{i});
    load('1.27-2.01.mat');
    
    % Plot
    subplot(4,2,i*2);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesLim, targetsTest(1,limIdx), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesLim, targetsTest(4,limIdx), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesLim, targetsTest(5,limIdx), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesLim, outputsTest(1,limIdx), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesLim, outputsTest(4,limIdx), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesLim, outputsTest(5,limIdx), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
%     if i == 1
%         legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A Prediction','LEMS E Prediction','LEMS F Prediction');
%     end
        
    for j = 1:8
        r2Arr(i, j) = coefDeter(targetsTest(j,:), outputsTest(j,:));
        rmseArr(i, j) = rmse(targetsTest(j,:), outputsTest(j,:));
        nrmseArr(i, j) = rmseArr(i, j) / range(targetsTest(j,:));
        meanBiasArr(i, j) = nanmean(outputsTest(j,:)) - nanmean(targetsTest(j,:));
    end
    statsArrRmse(i, 1) = rmse(mmTarg, mmOut);
    statsArrRmse(i, 2) = rmse(stdTarg, stdOut);
    statsArrNrmse(i, 1) = statsArrRmse(i, 1) / range(mmTarg);
    statsArrNrmse(i, 2) = statsArrRmse(i, 2) / range(stdTarg);
    
    % Remove first date because it's messy
    ax = gca; 
    xTickLabels = get(ax, 'XTickLabel');
    xTickLabels{1} = '';   % Needs to exist but make empty
    set(ax, 'XTickLabel', xTickLabels);
    
    cd('../..')
    
end


print('TS_Combined_1-27', '-depsc');

