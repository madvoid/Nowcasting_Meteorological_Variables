%% TS_Subplot.m
% Nipun Gunawardena
% Plot time series in accordance with new version of paper FOR LINEAR
% REGRESSION

clear all, close all, clc


%% Setup directories and variables
homeDir = cd;
dirs = {'../Specific Humidity','../Virtual Potential Temperature','../Wind U Component','../Wind V Component'};
ylabs = {'q', '\theta_v (K)', 'U (m/s)', 'V (m/s)'};


%% Plot 1.15-1.20 dates
fig1 = figure();
set(fig1, 'Units', 'normalized', 'Position', [0,0,1,1]);
r2Arr = zeros(4, 8);
statsArrRmse = zeros(4, 2);
statsArrNrmse = zeros(4, 2);
rmseArr = zeros(4, 8);
nrmseArr = zeros(4, 8);
meanBiasArr = zeros(4, 8);

for i = 1:length(dirs)
    % Load Data
    cd(dirs{i});
    load('1.15-1.20.mat');
    
    % Plot
    subplot(4,1,i);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesTest, targetsTest(1,:), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesTest, targetsTest(5,:), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesTest, targetsTest(6,:), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesTest, outputsTest(1,:), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesTest, outputsTest(5,:), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesTest, outputsTest(6,:), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
    legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A MLR','LEMS E MLR','LEMS F MLR');
    
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
    
end
cd(homeDir);
print('MLR_TS_Combined_1-15', '-depsc');

fileID = fopen('MLR_Stats_1-15_RMSE.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable                    &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L    & Range & StdDev \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$                         & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', rmseArr(1, 1), rmseArr(1, 2), rmseArr(1, 3), rmseArr(1, 4), rmseArr(1, 5), rmseArr(1, 6), rmseArr(1, 7), rmseArr(1, 8), statsArrRmse(1,1), statsArrRmse(1,2) );
fprintf(fileID, '$\\theta_v \\textrm{(K)}$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', rmseArr(2, 1), rmseArr(2, 2), rmseArr(2, 3), rmseArr(2, 4), rmseArr(2, 5), rmseArr(2, 6), rmseArr(2, 7), rmseArr(2, 8), statsArrRmse(2,1), statsArrRmse(2,2) );
fprintf(fileID, '$U (\\textrm{m s}^{-1})$    & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', rmseArr(3, 1), rmseArr(3, 2), rmseArr(3, 3), rmseArr(3, 4), rmseArr(3, 5), rmseArr(3, 6), rmseArr(3, 7), rmseArr(3, 8), statsArrRmse(3,1), statsArrRmse(3,2) );
fprintf(fileID, '$V (\\textrm{m s}^{-1})$    & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f       \n', rmseArr(4, 1), rmseArr(4, 2), rmseArr(4, 3), rmseArr(4, 4), rmseArr(4, 5), rmseArr(4, 6), rmseArr(4, 7), rmseArr(4, 8), statsArrRmse(4,1), statsArrRmse(4,2) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);

fileID = fopen('MLR_Stats_1-15_NRMSE.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable    &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L    & Range & StdDev \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$         & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', nrmseArr(1, 1), nrmseArr(1, 2), nrmseArr(1, 3), nrmseArr(1, 4), nrmseArr(1, 5), nrmseArr(1, 6), nrmseArr(1, 7), nrmseArr(1, 8), statsArrNrmse(1,1), statsArrNrmse(1,2) );
fprintf(fileID, '$\\theta_v$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', nrmseArr(2, 1), nrmseArr(2, 2), nrmseArr(2, 3), nrmseArr(2, 4), nrmseArr(2, 5), nrmseArr(2, 6), nrmseArr(2, 7), nrmseArr(2, 8), statsArrNrmse(2,1), statsArrNrmse(2,2) );
fprintf(fileID, '$U$         & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', nrmseArr(3, 1), nrmseArr(3, 2), nrmseArr(3, 3), nrmseArr(3, 4), nrmseArr(3, 5), nrmseArr(3, 6), nrmseArr(3, 7), nrmseArr(3, 8), statsArrNrmse(3,1), statsArrNrmse(3,2) );
fprintf(fileID, '$V$         & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f       \n', nrmseArr(4, 1), nrmseArr(4, 2), nrmseArr(4, 3), nrmseArr(4, 4), nrmseArr(4, 5), nrmseArr(4, 6), nrmseArr(4, 7), nrmseArr(4, 8), statsArrNrmse(4,1), statsArrNrmse(4,2) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);

fileID = fopen('MLR_Stats_1-15_MeanBias.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable    &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L     \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$                       & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', meanBiasArr(1, 1), meanBiasArr(1, 2), meanBiasArr(1, 3), meanBiasArr(1, 4), meanBiasArr(1, 5), meanBiasArr(1, 6), meanBiasArr(1, 7), meanBiasArr(1, 8) );
fprintf(fileID, '$\\theta_v \\textrm{(K)}$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f  \\\\ \n', meanBiasArr(2, 1), meanBiasArr(2, 2), meanBiasArr(2, 3), meanBiasArr(2, 4), meanBiasArr(2, 5), meanBiasArr(2, 6), meanBiasArr(2, 7), meanBiasArr(2, 8) );
fprintf(fileID, '$U (\\textrm{m s}^{-1})$  & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f  \\\\ \n', meanBiasArr(3, 1), meanBiasArr(3, 2), meanBiasArr(3, 3), meanBiasArr(3, 4), meanBiasArr(3, 5), meanBiasArr(3, 6), meanBiasArr(3, 7), meanBiasArr(3, 8) );
fprintf(fileID, '$V (\\textrm{m s}^{-1})$  & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f       \n', meanBiasArr(4, 1), meanBiasArr(4, 2), meanBiasArr(4, 3), meanBiasArr(4, 4), meanBiasArr(4, 5), meanBiasArr(4, 6), meanBiasArr(4, 7), meanBiasArr(4, 8) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);


%% Plot 1.27 - 2.01 dates
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
    
    % Plot
    subplot(4,1,i);
    hold all
    h(1) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS A
    h(2) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS E
    h(3) = plot(NaN, NaN, '.', 'MarkerSize', 12);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    plot(datesTest, targetsTest(1,:), '.', 'MarkerSize', 2);    % LEMS A
    plot(datesTest, targetsTest(5,:), '.', 'MarkerSize', 2);    % LEMS E
    plot(datesTest, targetsTest(6,:), '.', 'MarkerSize', 2);    % LEMS F
    set(gca,'ColorOrderIndex',1)
    h(4) = plot(datesTest, outputsTest(1,:), '-', 'LineWidth', 1);    % LEMS A
    h(5) = plot(datesTest, outputsTest(5,:), '-', 'LineWidth', 1);    % LEMS E
    h(6) = plot(datesTest, outputsTest(6,:), '-', 'LineWidth', 1);    % LEMS F
    
    xlabel('Time (CET)');
    ylabel(ylabs{i});
    dynamicDateTicks()
    legend(h, 'LEMS A Data','LEMS E Data','LEMS F Data', 'LEMS A MLR','LEMS E MLR','LEMS F MLR');
    
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
    
end
cd(homeDir);
print('MLR_TS_Combined_1-27', '-depsc');

fileID = fopen('MLR_Stats_1-27_RMSE.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable    &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L    & Range & StdDev \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$                         & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', rmseArr(1, 1), rmseArr(1, 2), rmseArr(1, 3), rmseArr(1, 4), rmseArr(1, 5), rmseArr(1, 6), rmseArr(1, 7), rmseArr(1, 8), statsArrRmse(1,1), statsArrRmse(1,2) );
fprintf(fileID, '$\\theta_v \\textrm{(K)}$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', rmseArr(2, 1), rmseArr(2, 2), rmseArr(2, 3), rmseArr(2, 4), rmseArr(2, 5), rmseArr(2, 6), rmseArr(2, 7), rmseArr(2, 8), statsArrRmse(2,1), statsArrRmse(2,2) );
fprintf(fileID, '$U (\\textrm{m s}^{-1})$    & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', rmseArr(3, 1), rmseArr(3, 2), rmseArr(3, 3), rmseArr(3, 4), rmseArr(3, 5), rmseArr(3, 6), rmseArr(3, 7), rmseArr(3, 8), statsArrRmse(3,1), statsArrRmse(3,2) );
fprintf(fileID, '$V (\\textrm{m s}^{-1})$    & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f       \n', rmseArr(4, 1), rmseArr(4, 2), rmseArr(4, 3), rmseArr(4, 4), rmseArr(4, 5), rmseArr(4, 6), rmseArr(4, 7), rmseArr(4, 8), statsArrRmse(4,1), statsArrRmse(4,2) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);

fileID = fopen('MLR_Stats_1-27_NRMSE.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable   &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L    & Range & StdDev \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$         & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', nrmseArr(1, 1), nrmseArr(1, 2), nrmseArr(1, 3), nrmseArr(1, 4), nrmseArr(1, 5), nrmseArr(1, 6), nrmseArr(1, 7), nrmseArr(1, 8), statsArrNrmse(1,1), statsArrNrmse(1,2) );
fprintf(fileID, '$\\theta_v$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', nrmseArr(2, 1), nrmseArr(2, 2), nrmseArr(2, 3), nrmseArr(2, 4), nrmseArr(2, 5), nrmseArr(2, 6), nrmseArr(2, 7), nrmseArr(2, 8), statsArrNrmse(2,1), statsArrNrmse(2,2) );
fprintf(fileID, '$U$         & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f  \\\\ \n', nrmseArr(3, 1), nrmseArr(3, 2), nrmseArr(3, 3), nrmseArr(3, 4), nrmseArr(3, 5), nrmseArr(3, 6), nrmseArr(3, 7), nrmseArr(3, 8), statsArrNrmse(3,1), statsArrNrmse(3,2) );
fprintf(fileID, '$V$         & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %2.2f & %2.2f       \n', nrmseArr(4, 1), nrmseArr(4, 2), nrmseArr(4, 3), nrmseArr(4, 4), nrmseArr(4, 5), nrmseArr(4, 6), nrmseArr(4, 7), nrmseArr(4, 8), statsArrNrmse(4,1), statsArrNrmse(4,2) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);

fileID = fopen('MLR_Stats_1-27_MeanBias.tex','w');
% fprintf(fileID, '\\begin{table}[]\n');
fprintf(fileID, '\\begin{tabular}{lcccccccc}\n');
fprintf(fileID, '\\topline\n');
fprintf(fileID, 'Variable    &   A   &  B    &  D    &  E    &  F    &  G    &  H    &  L     \\\\ \n');
fprintf(fileID, '\\midline\n');
fprintf(fileID, '$q$                       & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g & %1.2g  \\\\ \n', meanBiasArr(1, 1), meanBiasArr(1, 2), meanBiasArr(1, 3), meanBiasArr(1, 4), meanBiasArr(1, 5), meanBiasArr(1, 6), meanBiasArr(1, 7), meanBiasArr(1, 8) );
fprintf(fileID, '$\\theta_v \\textrm{(K)}$ & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f  \\\\ \n', meanBiasArr(2, 1), meanBiasArr(2, 2), meanBiasArr(2, 3), meanBiasArr(2, 4), meanBiasArr(2, 5), meanBiasArr(2, 6), meanBiasArr(2, 7), meanBiasArr(2, 8) );
fprintf(fileID, '$U (\\textrm{m s}^{-1})$  & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f  \\\\ \n', meanBiasArr(3, 1), meanBiasArr(3, 2), meanBiasArr(3, 3), meanBiasArr(3, 4), meanBiasArr(3, 5), meanBiasArr(3, 6), meanBiasArr(3, 7), meanBiasArr(3, 8) );
fprintf(fileID, '$V (\\textrm{m s}^{-1})$  & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f & %1.2f       \n', meanBiasArr(4, 1), meanBiasArr(4, 2), meanBiasArr(4, 3), meanBiasArr(4, 4), meanBiasArr(4, 5), meanBiasArr(4, 6), meanBiasArr(4, 7), meanBiasArr(4, 8) );
fprintf(fileID, '\\end{tabular}\n');
% fprintf(fileID, '\\end{table}\n');
fclose(fileID);
