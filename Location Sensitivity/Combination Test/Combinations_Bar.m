%% Combinations_Bar.m
% Nipun Gunawardena 
% Plot combinations analysis differently

clear all, close all, clc


%% Load and rename data
load('CombinationStatisticsDefault.mat');
mmDef = mmRmse;

load('CombinationStatistics14.mat');
mm14 = mmRmse;

load('CombinationStatisticsShuffle.mat');
mmShuf = mmRmse;

len = length(mmRmse);
combiNum = 1:len;

tot = [mmDef, mm14, mmShuf];


%% Plot
figure()
hold on
bar(tot);
xlabel('Combination Number');
ylabel('abs(min-max) RMSE');
legend('Default Seed', '14 Seed', 'Shuffle Seed');
ylim([0 4]);

rho = corr([mmDef, mm14, mmShuf], 'Type', 'Spearman');