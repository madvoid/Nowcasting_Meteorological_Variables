%% WindU_Plots.m
% Nipun Gunawardena
% Plot the data from Virtual_Potential_Temperature_Range1.m and
% Virtual_Potential_Temperature_Range2.m

clear all, close all, clc


%% Load first dataset
load('1.15-1.20.mat');

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));


%% Plot first dataset
fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,1);
hold all
plot(datesTest, targetsTest(1,:), 'o', 'MarkerSize', 2);    % LEMS A
plot(datesTest, targetsTest(2,:), 'o', 'MarkerSize', 2);    % LEMS B
plot(datesTest, targetsTest(3,:), 'o', 'MarkerSize', 2);    % LEMS D
set(gca,'ColorOrderIndex',1)
plot(datesTest, outputsTest(1,:), '-', 'LineWidth', 2);    % LEMS A
plot(datesTest, outputsTest(2,:), '-', 'LineWidth', 2);    % LEMS B
plot(datesTest, outputsTest(3,:), '-', 'LineWidth', 2);    % LEMS D
xlabel('Time (CET)');
ylabel('Wind U Component (m/s)');
title('1.15-1.20 Day Zoom');
dynamicDateTicks()
legend('LEMS A Data','LEMS B Data','LEMS D Data', 'LEMS A MLR','LEMS B MLR','LEMS D MLR');
print('MLR_windU_1-15_Zoom.eps', '-depsc');

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,3);
names = {'LEMS A', 'LEMS B', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS L'};
for i = 1:8
    h = subplot(2,4,i);
    hold on
    plot(targetsTest(i,:), outputsTest(i,:), 'o', 'MarkerSize', 2);
    p = polyfit(targetsTest(i,:), outputsTest(i,:), 1);
    pLine = polyval(p, [min(outputsTest(i,:)) max(outputsTest(i,:))]);
%     plot([min(outputsTest(i,:)) max(outputsTest(i,:))], [pLine(1) pLine(2)], 'r-', 'LineWidth', 2);
    nrmse = rmse(targetsTest(i,:), outputsTest(i,:)) / range(targetsTest(i,:));
    pr = refline(1, 0);
    axis square
    r2 = coefDeter(targetsTest(i,:), outputsTest(i,:));
    xlim = h.XLim;
    ylim = h.YLim;
    text(xlim(1)+(0.05*range(xlim)), ylim(2)-(0.05*range(ylim)), sprintf('NRMSE = %f', nrmse));
    xlabel('Data');
    ylabel('MLR Output');
    title(names{i});
end
print('MLR_windU_1-15_rSq.eps', '-depsc');

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,5);
hold on
plot(datesTest, mmOut, 'b:', 'LineWidth', 2);
plot(datesTest, mmTarg, 'r-');
plot(datesTest, stdOut, 'm:', 'LineWidth', 2);
plot(datesTest, stdTarg, 'k-');
xlabel('Date')
ylabel('Wind U Component Statistics (m/s)');
title(sprintf('Test Data || Range RMSE = %f || StdDev RMSE = %f', rmse(mmTarg, mmOut), rmse(stdTarg, stdOut)));
dynamicDateTicks()
legend('Range Output','Range Target','StdDev Output','StdDev Target');
print('MLR_windU_1-15_Stats.eps', '-depsc');



%% Load second dataset
clear all
load('1.27-2.01.mat');

% RMSE Function
rmse = @(y, ypred) sqrt(nanmean((y-ypred).^2));


%% Plot second dataset
fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,1);
hold all
plot(datesTest, targetsTest(1,:), 'o', 'MarkerSize', 2);    % LEMS A
plot(datesTest, targetsTest(2,:), 'o', 'MarkerSize', 2);    % LEMS B
plot(datesTest, targetsTest(3,:), 'o', 'MarkerSize', 2);    % LEMS D
set(gca,'ColorOrderIndex',1)
plot(datesTest, outputsTest(1,:), '-', 'LineWidth', 2);    % LEMS A
plot(datesTest, outputsTest(2,:), '-', 'LineWidth', 2);    % LEMS B
plot(datesTest, outputsTest(3,:), '-', 'LineWidth', 2);    % LEMS D
xlabel('Time (CET)');
ylabel('Wind U Component (m/s)');
title('1.27-2.01 Day Zoom');
dynamicDateTicks()
legend('LEMS A Data','LEMS B Data','LEMS D Data', 'LEMS A MLR','LEMS B MLR','LEMS D MLR');
print('MLR_windU_1-27_Zoom.eps', '-depsc');

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,3);
names = {'LEMS A', 'LEMS B', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS L'};
for i = 1:8
    h = subplot(2,4,i);
    hold on
    plot(targetsTest(i,:), outputsTest(i,:), 'o', 'MarkerSize', 2);
    p = polyfit(targetsTest(i,:), outputsTest(i,:), 1);
    pLine = polyval(p, [min(outputsTest(i,:)) max(outputsTest(i,:))]);
%     plot([min(outputsTest(i,:)) max(outputsTest(i,:))], [pLine(1) pLine(2)], 'r-', 'LineWidth', 2);
    nrmse = rmse(targetsTest(i,:), outputsTest(i,:)) / range(targetsTest(i,:));
    pr = refline(1, 0);
    axis square
    r2 = coefDeter(targetsTest(i,:), outputsTest(i,:));
    xlim = h.XLim;
    ylim = h.YLim;
    text(xlim(1)+(0.05*range(xlim)), ylim(2)-(0.05*range(ylim)), sprintf('NRMSE = %f', nrmse));
    xlabel('Data');
    ylabel('MLR Output');
    title(names{i});
end
print('MLR_windU_1-27_rSq.eps', '-depsc');

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
% subplot(3,2,5);
hold on
plot(datesTest, mmOut, 'b:', 'LineWidth', 2);
plot(datesTest, mmTarg, 'r-');
plot(datesTest, stdOut, 'm:', 'LineWidth', 2);
plot(datesTest, stdTarg, 'k-');
xlabel('Date')
ylabel('Wind U Component Statistics (m/s)');
title(sprintf('Test Data || Range RMSE = %f || StdDev RMSE = %f', rmse(mmTarg, mmOut), rmse(stdTarg, stdOut)));
dynamicDateTicks()
legend('Range Output','Range Target','StdDev Output','StdDev Target');
print('MLR_windU_1-27_Stats.eps', '-depsc');