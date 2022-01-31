%% Combinations_Sort_Analysis.m
% Nipun Gunawardena
% Plot sorted error

clear all, close all, clc


%% Load data
load('Sort14.mat');
idx14 = sortmmIdx;      % Rename because all files have same name

load('SortDefault.mat');
idxDefault = sortmmIdx;

load('SortShuffle.mat');
idxShuffle = sortmmIdx;


%% Plot
figure()
hold on
plot(idx14)
plot(idxDefault)
plot(idxShuffle)
ylabel('Combination Number');
xlabel('Increasing error ->');
legend('14','Default','Shuffle');

figure()
subplot(1,3,1)
plot(idx14, idxDefault, 'o');
xlabel('14 Seed Indices');
ylabel('Default Seed Indices');
title(sprintf('r = %f', coefCorr(idx14, idxDefault)));
subplot(1,3,2)
plot(idx14, idxShuffle, 'o');
xlabel('14 Seed Indices');
ylabel('Shuffle Seed Indices');
title(sprintf('r = %f', coefCorr(idx14, idxShuffle)));
subplot(1,3,3)
plot(idxShuffle, idxDefault, 'o');
xlabel('Shuffle Seed Indices');
ylabel('Default Seed Indices');
title(sprintf('r = %f', coefCorr(idxShuffle, idxDefault)));

print('ANN_Combo_Sort.eps', '-depsc');


%% Calculate Statistics
rho = corr([idxDefault, idx14, idxShuffle], 'Type', 'Spearman');
rho2 = corr([idxDefault, idx14, idxShuffle]);

